class TicketWorker
   include Sidekiq::Worker
   sidekiq_options queue: "high"
   sidekiq_options retry: false
   require "send_sms"

   def perform(phone_number, message, amount)
      #Check if gamer exists or create with segment A and return gamer
      gamer = Gamer.create_with(segment: 'A').find_or_create_by(phone_number: phone_number)

      case
      when amount.to_i >= 0 && amount.to_i < 1000
         #keep the money and sms the user and add name if gamer number is for MTN
         if !gamer.first_name.nil?
           message_content = gamer.first_name + ", Your recent wager of UGX.#{amount} is below the minimum of UGX.1000. Please increase the amount and try again"
         else
           message_content = "Your recent wager of UGX.#{amount} is below the minimum of UGX.1000. Please increase the amount and try again"
         end
         SendSMS.process_sms_now(receiver: phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])

      when amount.to_i > 50000
         #play 50000 and refund the excess
         refund_amount = (amount.to_i - 50000)
         ticket_id = process_ticket(phone_number, message, 50000)
         DisbursementWorker.perform_async(gamer.id, refund_amount, ticket_id)

      when amount.to_i >= 1000 && amount.to_i <= 50000
         process_ticket(phone_number: phone_number, message: message, amount: amount, first_name: gamer.first_name, last_name: gamer.last_name, gamer_id: gamer.id, segment: gamer.segment )
      end


   end

   def process_ticket(phone_number:, message:, amount:, first_name: nil, last_name: nil, gamer_id:, segment:)
      draw_time = ((Time.now - (Time.now.min % 10).minutes).beginning_of_minute + 10.minutes).strftime("%I:%M %p")

      #check if the data is purely numbers and 3 digits long
      #if not valid send invalid sms message and generate random 3 digit code
      #if valid, then create the ticket and send confirmation sms

      #remove all spaces, leading, trailing and between spaces
      message = message.gsub(/\s+/, '')
      data = message.scan(/\d/).join('')
      if data.length >= 3 && data.length < 5
         data = data[0..2]
      elsif data.length >= 5
         data = data[0..4]
      end
      keyword = message.gsub(/\d+/, '')

      reference = generate_ticket_reference
      network = ticket_network(phone_number)
      max_win = amount.to_i * 200

      if data.length == 3 #should also check that its below 10
         ticket = Tickets.new(gamer_id: gamer_id ,phone_number: phone_number, data: data, amount: amount.to_i, reference: reference, network: network, first_name: first_name, last_name: last_name, keyword: keyword, game: "Supa3",segment: segment)
         if ticket.save
            #Send SMS with confirmation and add gamer name if number is for MTN
            if first_name == nil
              message_content = first_name + ", Your lucky numbers: #{data} are entered in the next draw at #{draw_time}. You could win UGX.#{max_win}! Ticket ID: #{reference}. You have been entered into the Supa Jackpot. Thank you for playing #{ENV['GAME']}"
            else
              message_content = "Your lucky numbers: #{data} are entered in the next draw at #{draw_time}. You could win UGX.#{max_win}! Ticket ID: #{reference}. You have been entered into the Supa Jackpot. Thank you for playing #{ENV['GAME']}"
            end
            if SendSMS.process_sms_now(receiver: phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID']) == true
               ticket.update_attributes(confirmation: true)
            end
         end

      elsif data.length == 5
         max_win = amount.to_i * 500
         ticket = Ticket.new(gamer_id: gamer_id ,phone_number: phone_number, data: data, amount: amount.to_i, reference: reference, network: network, first_name: first_name, last_name: last_name, keyword: keyword, game: "Supa5", segment: segment)
         if ticket.save
            #Send SMS with confirmation
            if first_name == nil
              message_content = first_name + ", Your lucky numbers: #{data} are entered in the next draw at #{draw_time}. You could win UGX.#{max_win}! Ticket ID: #{reference}. You have been entered into the BIG 5."
            else
              message_content = "Your lucky numbers: #{data} are entered in the next draw at #{draw_time}. You could win UGX.#{max_win}! Ticket ID: #{reference}. You have been entered into the BIG 5."
            end
            if SendSMS.process_sms_now(receiver: phone_number, content: message_content, sender_id: ENV['SUPA5_SENDER_ID']) == true
               ticket.update_attributes(confirmation: true)
            end
         end

      else
         #generate random numbers
         random_data = generate_random_data
         ticket = Ticket.new(gamer_id: gamer_id ,phone_number: phone_number, data: random_data, amount: amount.to_i, reference: reference, network: network, first_name: first_name, last_name: last_name, keyword: keyword, game: "Supa3",segment: segment)
         if ticket.save
            #Send SMS with the confirmation and random number and add gamer name if number is for MTN
            if first_name == nil
              message_content = first_name + ", We didn't recognise your numbers so we bought you a LUCKY PICK ticket #{random_data} entered in to #{draw_time} draw. You could win UGX.#{max_win}, Ticket ID: #{reference} Thank you for playing #{ENV['GAME']}."
            else
              message_content = "We didn't recognise your numbers so we bought you a LUCKY PICK ticket #{random_data} entered in to #{draw_time} draw. You could win UGX.#{max_win}, Ticket ID: #{reference} Thank you for playing #{ENV['GAME']}."
            end
            if SendSMS.process_sms_now(receiver: phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID']) == true
               ticket.update_attributes(confirmation: true)
            end
         end
      end
      return ticket.id
   end

   def ticket_network(phone_number)
      case phone_number
      when /^(25677|25678|25639)/
         return "MTN Uganda"
      when /^(25670|25675)/
         return "Airtel Uganda"
      else
         return "UNDEFINED"
      end
   end

   def generate_random_data()
      random_numbers = []
      while random_numbers.length != 3
         random_numbers = SecureRandom.hex(50).scan(/\d/).uniq.sample(3).map(&:to_i)
      end
      return random_numbers.join("")
   end

   def generate_ticket_reference
      begin
         ref = rand(36**8).to_s(36).upcase
      end while Ticket.where(reference: ref).exists?
      return ref
   end
end
