class Supa5DrawWorker
   include Sidekiq::Worker
   sidekiq_options queue: "high"
   sidekiq_options retry: false

   require 'send_sms'
   MATCHED_FIVE = 500
   MATCHED_FIVE_ANY = 10
   MATCHED_FOUR = 400
   MATCHED_FOUR_ANY = 5
   MATCHED_THREE = 200
   MATCHED_TWO = 2
   MATCHED_ONE = 0


   def perform(start_time, end_time)

      #create the draw and later update with ticket stats
      @draw = Draw.create(draw_time: end_time)

      #extract draw id
      draw_id = @draw.id
      #@draw = Draw.find(draw_id)

      ## Update all tickets in that range with the draw ID
      Ticket.where("created_at <= ? AND created_at >= ? AND game = ?", end_time, start_time, "Supa5").update_all(draw_id: draw_id)
      
      #generate random number for winnings
      draw_numbers = draw_sequencer(draw_id)


      # check if the there is an existing offer or bonus
      # if DrawOffer.where("expiry_time > ? ",Time.now).exists?
      #    #run special bonus draws
      #    Ticket.where("created_at <= ? AND created_at >= ? AND game = ?", end_time, start_time, "Supa5").find_each(batch_size: 1000) do |ticket|
      #       #find the gamer segment
      #       gamer_segment = Gamer.find(ticket.gamer_id).segment
      #       segment_offers = DrawOffer.where("expiry_time > ? AND segment = ? ",Time.now,gamer_segment)
      #       if segment_offers.present?
      #          #load new multipliers and execute
      #          process_ticket(draw_id, draw_numbers, ticket, segment_offers.multiplier_five,segment_offers.multiplier_four,segment_offers.multiplier_three, segment_offers.multiplier_two, segment_offers.multiplier_one)
      #       else
      #         #execute the draw
      #         process_ticket(draw_id, draw_numbers, ticket, MATCHED_FIVE , MATCHED_FOUR, MATCHED_THREE, MATCHED_TWO, MATCHED_ONE)
      #
      #       end
      #
      #    end
      #
      # else
      #    #run normally
      #    Ticket.where("created_at <= ? AND created_at >= ? AND game = ?", end_time, start_time, "Supa5").find_each(batch_size: 1000) do |ticket|
      #       #execute the draw
      #       process_ticket(draw_id, draw_numbers, ticket, MATCHED_FIVE , MATCHED_FOUR, MATCHED_THREE, MATCHED_TWO, MATCHED_ONE)
      #
      #    end
      #
      # end
      #run normally
      Ticket.where("created_at <= ? AND created_at >= ? AND game = ?", end_time, start_time, "Supa5").find_each(batch_size: 1000) do |ticket|
         #execute the draw
         process_ticket(draw_id, draw_numbers, ticket, MATCHED_FIVE , MATCHED_FIVE_ANY, MATCHED_FOUR, MATCHED_FOUR_ANY, MATCHED_THREE, MATCHED_TWO, MATCHED_ONE)

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
      undefined_tickets = Ticket.where("network = ? AND draw_id = ?", other, draw_id).count()
      rtp = revenue > 0 ? ((payout / revenue) * 100) : 0
      unique_users = Ticket.where(draw_id: draw_id).select('DISTINCT gamer_id').count()
      no_match = Ticket.where(draw_id: draw_id, number_matches: 0).count()
      one_match = Ticket.where(draw_id: draw_id, number_matches: 1).count()
      two_match = Ticket.where(draw_id: draw_id, number_matches: 2).count()
      three_match = Ticket.where(draw_id: draw_id, number_matches: 3).count()
      four_match = Ticket.where(draw_id: draw_id, number_matches: 4).count()
      five_match = Ticket.where(draw_id: draw_id, number_matches: 5).count()
      new_users = Gamer.where("created_at <= ? AND created_at >= ?", end_time, start_time).count()
      winning_number = draw_numbers.join("")

      @draw.update_attributes(revenue:revenue, payout: payout, no_match: no_match, one_match: one_match, two_match: two_match, three_match: three_match, four_match: four_match, five_match: five_match, ticket_count: ticket_count, mtn_tickets: mtn_tickets,
      airtel_tickets: airtel_tickets, undefined_tickets: undefined_tickets, users: unique_users, rtp: rtp, winning_number: winning_number, new_users: new_users, game: "Supa5")

   end

   def process_ticket(draw_id, draw_numbers, ticket, matched_five, matched_five_any, matched_four, matched_four_any, matched_three, matched_two, matched_one)

      #check number of matches
      ticket_numbers = ticket.data.split("").map(&:to_i)
      number_matches = (draw_numbers & ticket_numbers).count()
      winning_number = draw_numbers.join("")

      if ticket_numbers == draw_numbers #number_matches == 5 && draw_numbers == ticket_numbers
         win = (ticket.amount).to_i * matched_five
         ticket.update_attributes(number_matches: number_matches, win_amount: win, paid: false, winning_number: winning_number)
         #send confirmation message
         message_content = "CONGRATS! Your lucky numbers: #{ticket.data} for ##{draw_id} matched #{number_matches} numbers! You've won UGX.#{win}! Winning numbers: #{draw_numbers.join("")}. Play Again to increase your entries into the BIG 5."
         SendSMS.process_sms_now(receiver: ticket.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID']) #change this
         #process payments
         win_after_taxes = (win.to_i * 0.85)
         DisbursementWorker.perform_async(ticket.gamer_id, win_after_taxes, ticket.id)

      elsif (number_matches == 5) && (ticket_numbers != draw_numbers)
         win = (ticket.amount).to_i * matched_five_any
         ticket.update_attributes(number_matches: number_matches, win_amount: win, paid: false, winning_number: winning_number)
         #send confirmation message
         message_content = "CONGRATS! Your lucky numbers: #{ticket.data} for ##{draw_id} matched #{number_matches} numbers without sequence! You've won UGX.#{win}! Winning numbers: #{draw_numbers.join("")}. Play Again to increase your entries into the BIG 5."
         SendSMS.process_sms_now(receiver: ticket.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID']) #change this
         #process payments
         win_after_taxes = (win.to_i * 0.85)
         DisbursementWorker.perform_async(ticket.gamer_id, win_after_taxes, ticket.id)

      elsif (ticket_numbers[0..3] == draw_numbers[0..3]) &&  (ticket_numbers[0..4] != draw_numbers[0..4])
         win = (ticket.amount).to_i * matched_four
         ticket.update_attributes(number_matches: number_matches, win_amount: win, paid: false, winning_number: winning_number)
         #send confirmation message
         message_content = "CONGRATS! Your lucky numbers: #{ticket.data} for ##{draw_id} matched 4 numbers in sequence! You've won UGX.#{win}! Winning numbers: #{draw_numbers.join("")}. Play Again to increase your entries into the BIG 5."
         SendSMS.process_sms_now(receiver: ticket.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])
         #process payment
         win_after_taxes = (win.to_i * 0.85)
         DisbursementWorker.perform_async(ticket.gamer_id, win_after_taxes, ticket.id)

      elsif (number_matches == 4) && (ticket_numbers[0..3] != draw_numbers[0..3])
         win = (ticket.amount).to_i * matched_four_any
         ticket.update_attributes(number_matches: number_matches, win_amount: win, paid: false, winning_number: winning_number)
         #send confirmation message
         message_content = "CONGRATS! Your lucky numbers: #{ticket.data} for ##{draw_id} matched #{number_matches} numbers without sequence! You've won UGX.#{win}! Winning numbers: #{draw_numbers.join("")}. Play Again to increase your entries into the BIG 5."
         SendSMS.process_sms_now(receiver: ticket.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID']) #change this
         #process payments
         win_after_taxes = (win.to_i * 0.85)
         DisbursementWorker.perform_async(ticket.gamer_id, win_after_taxes, ticket.id)

      elsif (ticket_numbers[0..2] == draw_numbers[0..2]) &&  (ticket_numbers[0..3] != draw_numbers[0..3])
         win = (ticket.amount).to_i * matched_three
         ticket.update_attributes(number_matches: number_matches, win_amount: win, paid: false, winning_number: winning_number)
         #send confirmation message
         message_content = "CONGRATS! Your lucky numbers: #{ticket.data} for ##{draw_id} matched 3 numbers in sequence! You've won UGX.#{win}! Winning numbers: #{draw_numbers.join("")}. Play Again to increase your entries into the BIG 5."
         SendSMS.process_sms_now(receiver: ticket.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])
         #process payment
         win_after_taxes = (win.to_i * 0.85)
         DisbursementWorker.perform_async(ticket.gamer_id, win_after_taxes, ticket.id)

      elsif (ticket_numbers[0..1] == draw_numbers[0..1]) &&  (ticket_numbers[0..2] != draw_numbers[0..2])
         win = (ticket.amount).to_i * matched_two
         ticket.update_attributes(number_matches: number_matches, win_amount: win, paid: false, winning_number: winning_number)
         #send confirmation message
         message_content = "CONGRATS! Your lucky numbers: #{ticket.data} for ##{draw_id} matched 2 numbers in sequence! You've won UGX.#{win}! Winning numbers: #{draw_numbers.join("")}. Play Again to increase your entries into the BIG 5."
         SendSMS.process_sms_now(receiver: ticket.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])
         #process payment
         if win > 0
            DisbursementWorker.perform_async(ticket.gamer_id, win, ticket.id)
         end
      else
         win = (ticket.amount).to_i * matched_one
         ticket.update_attributes(number_matches: number_matches, win_amount: win, paid: false, winning_number: winning_number)
         #send confirmation message
         if !ticket.first_name.nil?
           message_content = ticket.first_name + ",#{draw_numbers.join("")} are the winning numbers for draw ##{draw_id}. You have not matched any number in sequence. Play Now & win in the next 10mins + increase your BIG 5 Entries"
         else
           message_content = "Hi,#{draw_numbers.join("")} are the winning numbers for draw ##{draw_id}. You have not matched any number in sequence. Play Now & win in the next 10mins + increase your BIG 5 Entries"
         end
         SendSMS.process_sms_now(receiver: ticket.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])
         #process payment

      end
   end

   ## Draw sequencer
   def draw_sequencer(draw_id)
      draw_numbers = []

      # First check if Draw ID is capable of a win
      if (draw_id % 3) != 0
         while (draw_numbers.length != 5 || draw_numbers == [1,2,3,4,5] || Draw.where("winning_number = ? AND created_at >= ? AND game = ?", draw_numbers.join(""), Time.now - 24.hours, "Supa5").exists?)
            draw_numbers = random_number_generator()
         end

         return draw_numbers
         
      else
         # Start the Draw winning number generation
         while (draw_numbers.length != 5 || draw_numbers == [1,2,3,4,5] || Draw.where("winning_number = ? AND created_at >= ? AND game = ?", draw_numbers.join(""), Time.now - 24.hours, "Supa5").exists?)
            loop do
               draw_numbers = random_number_generator()
               if Ticket.where("draw_id = ? AND data = ? ", draw_id, draw_numbers.join(",")).empty?
                  break
               end
            end 
         end

         return draw_numbers
      end
      
   end

   def random_number_generator
      random_numbers = SecureRandom.hex(50).scan(/\d/).uniq.sample(5).map(&:to_i)

      return random_numbers
   end


end
