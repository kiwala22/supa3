class DrawWorker
   include Sidekiq::Worker
   sidekiq_options queue: "default"
   sidekiq_options retry: false

   require 'send_sms'

   def perform(start_time, end_time)

      #create the draw and later update with ticket stats
      @draw = Draw.create(draw_time: end_time)

      #generate random number for winnings
      draw_numbers = []
      while draw_numbers.length != 3
           draw_numbers = SecureRandom.hex(50).scan(/\d/).uniq.sample(3).map(&:to_i)
      end

      #query all tickets between start and stop time, mark matching numbers and send appropriate messag
      Ticket.where("created_at <= ? AND created_at >= ?", end_time, start_time).find_each(batch_size: 1000) do |ticket|
         #update with draw number
         ticket.update_attributes(draw_id: @draw.id)
         #check number of matches
         ticket_numbers = ticket.data.split(",").map(&:to_i)
         number_matches = (draw_numbers & ticket_numbers).count()

         if draw_numbers == ticket_numbers
            win = (ticket.amount).to_i * 200
            ticket.update_attributes(number_matches: number_matches, win_amount: win, paid: false)
            #send confirmation message
            message_content = "Winning Numbers for draw ##{@draw.id} are #{draw_numbers.join(",")}. You matched #{number_matches} in-line numbers. You have won UGX #{win}. Thank you for playing #{ENV['GAME']}"
            #SendSMS.process_sms_now(receiver: ticket.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])
            #process payments

         elsif draw_numbers.first(2) == ticket_numbers.first(2) || draw_numbers.last(2) == ticket_numbers.last(2)
            win = (ticket.amount).to_i * 5
            ticket.update_attributes(number_matches: number_matches, win_amount: win, paid: false)
            #send confirmation message
            message_content = "Winning Numbers for draw ##{@draw.id} are #{draw_numbers.join(",")}. You matched #{number_matches}  in-line numbers. You have won UGX #{win}. Thank you for playing #{ENV['GAME']}"
            #SendSMS.process_sms_now(receiver: ticket.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])

            #process the payment

         elsif number_matches == 3
            win = (ticket.amount).to_i * 5
            ticket.update_attributes(number_matches: number_matches, win_amount: win, paid: false)
            #send confirmation message
            message_content = "Winning Numbers for draw ##{@draw.id} are #{draw_numbers.join(",")}. You matched #{number_matches} numbers.  Thank you for playing #{ENV['GAME']}"
            #SendSMS.process_sms_now(receiver: ticket.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])
            #process payment
         elsif number_matches == 2
            win = (ticket.amount).to_i * 2
            ticket.update_attributes(number_matches: number_matches, win_amount: win, paid: false)
            #send confirmation message
            message_content = "Winning Numbers for draw ##{@draw.id} are #{draw_numbers.join(",")}. You matched #{number_matches} numbers.  Thank you for playing #{ENV['GAME']}"
            #SendSMS.process_sms_now(receiver: ticket.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])
            #process payment
         else
            win = (ticket.amount).to_i * 0
            ticket.update_attributes(number_matches: number_matches, win_amount: win, paid: false)
            #send confirmation message
            message_content = "Winning Numbers for draw ##{@draw.id} are #{draw_numbers.join(",")}. You matched #{number_matches} numbers.  Thank you for playing #{ENV['GAME']}"
            #SendSMS.process_sms_now(receiver: ticket.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])
            #process payment

         end
      end
      #run stats for the draw and update the status
      #total number fo tickets, number of matches, total ticket amount, payouts
      sleep 10
      revenue = Ticket.where("created_at <= ? AND created_at >= ?", end_time, start_time).sum(:amount)
      ticket_count = Ticket.where("created_at <= ? AND created_at >= ?", end_time, start_time).count()
      payout = Ticket.where("created_at <= ? AND created_at >= ?", end_time, start_time).sum(:win_amount)
      no_match = Ticket.where("created_at <= ? AND created_at >= ? AND number_matches = ?", end_time, start_time, 0).count()
      one_match = Ticket.where("created_at <= ? AND created_at >= ? AND number_matches = ?", end_time, start_time, 1).count()
      two_match = Ticket.where("created_at <= ? AND created_at >= ? AND number_matches = ?", end_time, start_time, 2).count()
      three_match = Ticket.where("created_at <= ? AND created_at >= ? AND number_matches = ?", end_time, start_time, 3).count()
      four_match = Ticket.where("created_at <= ? AND created_at >= ? AND number_matches = ?", end_time, start_time, 4).count()
      five_match = Ticket.where("created_at <= ? AND created_at >= ? AND number_matches = ?", end_time, start_time, 5).count()

      @draw.update_attributes(revenue:revenue, payout: payout, no_match: no_match, one_match: one_match, two_match: two_match, three_match: three_match, four_match: four_match, five_match: five_match, ticket_count: ticket_count)

   end
end
