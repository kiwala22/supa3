class DrawWorker
   include Sidekiq::Worker
   sidekiq_options queue: "default"
   sidekiq_options retry: false

   require 'send_sms'

   def perform(start_time, end_time)

      #create the draw and later update with ticket stats
      @draw = Draw.create(draw_time: end_time)

      #generate random number for winnings
      begin
         draw_numbers = SecureRandom.uuid.scan(/\d/).uniq.sample(3).join("")
      end while draw_numbers === /\d{3}$/


      #query all tickets between start and stop time, mark matching numbers and send appropriate messag
      Ticket.where("created_at <= ? AND created_at >= ?", end_time, start_time).in_batches(of: 1000) do |ticket|
         #update with draw number
         ticket.update_attribute(draw_id: @draw.id)
         #check number of matches
         data_arr = ticket.data.split("").uniq.map(&:to_i)
         win_arr = draw_numbers.split("").uniq.map(&:to_i)
         matches = (data_arr & win_arr).count()
         case matches
            when 0 || 1
               win = ticket.amount * 0
               ticket.update_attributes(number_matches: matches, win_amount: win, paid: false)
               #send confirmation message
               message_content = "Winning Numbers for draw ##{@draw.id} are #{draw_numbers}. You matched #{matches} numbers.  Thank you for playing #{ENV['GAME']}"
               SendSMS.process_sms_now(receiver: ticket.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])

            when 2
               win = ticket.amount * 2
               ticket.update_attributes(number_matches: matches, win_amount: win, paid: false)
               #send confirmation message
               message_content = "Winning Numbers for draw ##{@draw.id} are #{draw_numbers}. You matched #{matches} numbers. You have won UGX #{win}. Thank you for playing #{ENV['GAME']}"
               SendSMS.process_sms_now(receiver: ticket.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])

               #process the payment
            when 3
               win = ticket.amount * 200
               ticket.update_attributes(number_matches: matches, win_amount: win, paid: false)
               #send confirmation message
               message_content = "Winning Numbers for draw ##{@draw.id} are #{draw_numbers}. You matched #{matches} numbers. You have won UGX #{win}. Thank you for playing #{ENV['GAME']}"
               SendSMS.process_sms_now(receiver: ticket.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])

            #process the payment
         end

      end

      #run stats for the draw and update the status
      #total number fo tickets, number of matches, total ticket amount, payouts
      sleep 10
      revenue = Ticket.where("created_at <= ? AND created_at >= ?", end_time, start_time).sum(:amount)
      payout = Ticket.where("created_at <= ? AND created_at >= ?", end_time, start_time).sum(:win_amount)
      no_match = Ticket.where("created_at <= ? AND created_at >= ? AND number_matches = ?", end_time, start_time, 0).count()
      one_match = Ticket.where("created_at <= ? AND created_at >= ? AND number_matches = ?", end_time, start_time, 1).count()
      two_match = Ticket.where("created_at <= ? AND created_at >= ? AND number_matches = ?", end_time, start_time, 2).count()
      three_match = Ticket.where("created_at <= ? AND created_at >= ? AND number_matches = ?", end_time, start_time, 3).count()

      @draw.update_attributes(revenue:revenue, payout: payout, no_match: no_match, one_match: one_match, two_match: two_match, three_match: three_match)

   end
end
