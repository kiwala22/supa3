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

      #extract draw id
      draw_id = @draw.id
      #generate random number for winnings
      draw_numbers = []
      while (draw_numbers.length != 3 || draw_numbers == [1,2,3] || Draw.where("winning_number = ? AND created_at >= ?", draw_numbers.join(""), Time.now-24.hours).exists?)
           draw_numbers = SecureRandom.hex(50).scan(/\d/).uniq.sample(3).map(&:to_i)
      end

      #update with draw ID
      Ticket.where("created_at <= ? AND created_at >= ?", end_time, start_time).update_all(draw_id: draw_id)


      # check if the there is an existing offer or bonus
      if DrawOffer.where("expiry_time > ? ",Time.now).exists?
         #run special bonus draws
         Ticket.where("created_at <= ? AND created_at >= ?", end_time, start_time).find_each(batch_size: 1000) do |ticket|
            #find the gamer segment
            gamer_segment = Gamer.find(ticket.gamer_id).segment
            segment_offers = DrawOffer.where("expiry_time > ? AND segment = ? ",Time.now, gamer_segment).last
            if segment_offers.present?
               #load new multipliers and execute
               process_ticket(draw_id, draw_numbers, ticket, segment_offers.multiplier_three, segment_offers.multiplier_two, segment_offers.multiplier_one)
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
      #network definations
      mtn = "MTN Uganda"
      airtel = "Airtel Uganda"
      other = "UNDEFINED"
      #total number fo tickets, number of matches, total ticket amount, payouts
      sleep 10
      revenue = Ticket.where(draw_id: draw_id).sum(:amount)
      ticket_count = Ticket.where(draw_id: draw_id).count()
      payout = Ticket.where(draw_id: draw_id).sum(:win_amount)
      mtn_tickets = Ticket.where("network = ? AND draw_id = ?", mtn, draw_id).count()
      airtel_tickets = Ticket.where("network = ? AND draw_id = ?", airtel, draw_id).count()
      rtp = revenue > 0 ? ((payout / revenue) * 100) : 0
      unique_users = Ticket.where(draw_id: draw_id).select('DISTINCT gamer_id').count()
      no_match = Ticket.where(draw_id: draw_id, number_matches: 0).count()
      one_match = Ticket.where(draw_id: draw_id, number_matches: 1).count()
      two_match = Ticket.where(draw_id: draw_id, number_matches: 2).count()
      three_match = Ticket.where(draw_id: draw_id, number_matches: 3).count()
      new_users = Gamer.where("created_at <= ? AND created_at >= ?", end_time, start_time).count()
      winning_number = draw_numbers.join("")

      @draw.update_attributes(revenue:revenue, payout: payout, no_match: no_match, one_match: one_match, two_match: two_match, three_match: three_match, ticket_count: ticket_count, mtn_tickets: mtn_tickets,
      airtel_tickets: airtel_tickets, users: unique_users, rtp: rtp, winning_number: winning_number, new_users: new_users)

   end

   def process_ticket(draw_id, draw_numbers, ticket, matched_three, matched_two, matched_one)

      #check number of matches
      ticket_numbers = ticket.data.split("").map(&:to_i)
      number_matches = (draw_numbers & ticket_numbers).count()
      winning_number = draw_numbers.join("")

      if number_matches == 3 && draw_numbers == ticket_numbers
         win = (ticket.amount).to_i * matched_three
         ticket.update_attributes(number_matches: number_matches, win_amount: win, paid: false, winning_number: winning_number)
         #send confirmation message
         message_content = "CONGRATS! Your ticket #{ticket.reference} for ##{draw_id} matched #{number_matches} numbers! You've won UGX.#{win}! Winning numbers: #{draw_numbers.join("")}. Play Again to increase your entries into the Supa Jackpot"
         SendSMS.process_sms_now(receiver: ticket.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])
         #process payments
         win_after_taxes = (win.to_i * 0.85)
         DisbursementWorker.perform_async(ticket.gamer_id, win_after_taxes, ticket.id)

      elsif number_matches == 3 && draw_numbers != ticket_numbers
         win = (ticket.amount).to_i * matched_two
         ticket.update_attributes(number_matches: number_matches, win_amount: win, paid: false, winning_number: winning_number)
         #send confirmation message
         message_content = "CONGRATS! Your ticket #{ticket.reference} for ##{draw_id} matched #{number_matches} numbers without sequence! You've won UGX.#{win}! Winning numbers: #{draw_numbers.join("")}. Play Again to increase your entries into the Supa Jackpot"
         SendSMS.process_sms_now(receiver: ticket.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])
         #process payment
         DisbursementWorker.perform_async(ticket.gamer_id, win, ticket.id)

      elsif number_matches == 2
         win = (ticket.amount).to_i * matched_two
         ticket.update_attributes(number_matches: number_matches, win_amount: win, paid: false, winning_number: winning_number)
         #send confirmation message
         message_content = "CONGRATS! Your ticket #{ticket.reference} for ##{draw_id} matched #{number_matches} numbers! You've won UGX.#{win}! Winning numbers: #{draw_numbers.join("")}. Play Again to increase your entries into the Supa Jackpot"
         SendSMS.process_sms_now(receiver: ticket.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])
         #process payment
         DisbursementWorker.perform_async(ticket.gamer_id, win, ticket.id)

      elsif number_matches == 1
         win = (ticket.amount).to_i * matched_one
         ticket.update_attributes(number_matches: number_matches, win_amount: win, paid: false, winning_number: winning_number)
         #send confirmation message
         message_content = "Hi,#{draw_numbers.join("")} are the winning numbers for draw ##{draw_id}. You matched #{number_matches} numbers this time. Play Now & win in the next 10mins + increase your Jackpot Entries"
         SendSMS.process_sms_now(receiver: ticket.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])
         #process payment
         if win > 0
            DisbursementWorker.perform_async(ticket.gamer_id, win, ticket.id)
         end

      else
         win = (ticket.amount).to_i * 0
         ticket.update_attributes(number_matches: number_matches, win_amount: win, paid: false, winning_number: winning_number)
         #send confirmation message
         message_content = "Hi,#{draw_numbers.join("")} are the winning numbers for draw ##{draw_id}. You matched #{number_matches} numbers this time. Play Now & win in the next 10mins + increase your Jackpot Entries"
         SendSMS.process_sms_now(receiver: ticket.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])
         #process payment

      end
   end
end
