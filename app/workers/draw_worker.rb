class DrawWorker
   include Sidekiq::Worker
   sidekiq_options queue: "high"
   sidekiq_options retry: false

   require 'send_sms'
   MATCHED_THREE = 200
   MATCHED_TWO = 2
   MATCHED_ONE = 0


   def perform(start_time, end_time)

      #create the draw and later update with ticket stats
      @draw = Draw.create(draw_time: end_time)

      #generate random number for winnings
      draw_numbers = []
      while draw_numbers.length != 3
           draw_numbers = SecureRandom.hex(50).scan(/\d/).uniq.sample(3).map(&:to_i)
      end

      # check if the there is an existing offer or bonus
      if DrawOffer.where("expiry_time > ? ",Time.now).exists?
         #run special bonus draws
         Ticket.where("created_at <= ? AND created_at >= ?", end_time, start_time).find_each(batch_size: 1000) do |ticket|
            #find the gamer segment
            gamer_segment = Gamer.find(ticket.gamer_id).segment
            segment_offers = DrawOffer.where("expiry_time > ? AND segment = ? ",Time.now,gamer_segment)
            if segment_offers.present?
               #load new multipliers and execute 
               process_ticket(draw_id, draw_numbers, ticket, matchedThree, matchedTwo, matchedOne)
               
            else
              #execute the draw 
              process_ticket(draw_id, draw_numbers, ticket, MATCHED_THREE, MATCHED_TWO, MATCHED_ONE)
              
            end
            
         end

      else
         #run normally
         Ticket.where("created_at <= ? AND created_at >= ?", end_time, start_time).find_each(batch_size: 1000) do |ticket|
            #execute the draw
            process_ticket(draw_id, draw_numbers, ticket, MATCHED_THREE, MATCHED_TWO, MATCHED_ONE)
                  
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
      # four_match = Ticket.where("created_at <= ? AND created_at >= ? AND number_matches = ?", end_time, start_time, 4).count()
      # five_match = Ticket.where("created_at <= ? AND created_at >= ? AND number_matches = ?", end_time, start_time, 5).count()

      @draw.update_attributes(revenue:revenue, payout: payout, no_match: no_match, one_match: one_match, two_match: two_match, three_match: three_match, ticket_count: ticket_count)

   end

   def process_ticket(draw_id, draw_numbers, ticket, matched_three, matched_two, matched_one)
      #update with draw number
      ticket.update_attributes(draw_id: draw_id)

      #check number of matches
      ticket_numbers = ticket.data.split(",").map(&:to_i)
      number_matches = (draw_numbers & ticket_numbers).count()

      if number_matches == 3 && draw_numbers == ticket_numbers
         win = (ticket.amount).to_i * matched_three
         ticket.update_attributes(number_matches: number_matches, win_amount: win, paid: false)
         #send confirmation message
         message_content = "Winning Numbers for draw ##{draw_id} are #{draw_numbers.join(",")}. You matched #{number_matches} in-line numbers. You have won UGX #{win}. Thank you for playing #{ENV['GAME']}"
         #SendSMS.process_sms_now(receiver: ticket.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])
         #process payments

      elsif number_matches == 3 && draw_numbers != ticket_numbers
         win = (ticket.amount).to_i * matched_two
         ticket.update_attributes(number_matches: number_matches, win_amount: win, paid: false)
         #send confirmation message
         message_content = "Winning Numbers for draw ##{draw_id} are #{draw_numbers.join(",")}. You matched #{number_matches} numbers.  Thank you for playing #{ENV['GAME']}"
         #SendSMS.process_sms_now(receiver: ticket.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])
         #process payment
      elsif number_matches == 2
         win = (ticket.amount).to_i * matched_two
         ticket.update_attributes(number_matches: number_matches, win_amount: win, paid: false)
         #send confirmation message
         message_content = "Winning Numbers for draw ##{draw_id} are #{draw_numbers.join(",")}. You matched #{number_matches} numbers.  Thank you for playing #{ENV['GAME']}"
         #SendSMS.process_sms_now(receiver: ticket.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])
         #process payment
      else
         win = (ticket.amount).to_i * 0
         ticket.update_attributes(number_matches: number_matches, win_amount: win, paid: false)
         #send confirmation message
         message_content = "Winning Numbers for draw ##{draw_id} are #{draw_numbers.join(",")}. You matched #{number_matches} numbers.  Thank you for playing #{ENV['GAME']}"
         #SendSMS.process_sms_now(receiver: ticket.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])
         #process payment

      end
   end
end
