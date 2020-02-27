class TicketWorker
   include Sidekiq::Worker
   sidekiq_options queue: "high"
   sidekiq_options retry: false
   require "send_sms"

   def perform(phone_number, message, amount)
      #Check if gamer exists or create with segment A and return gamer
      gamer = Gamer.create_with(segment: 'A').find_or_create_by(phone_number: phone_number)

      case amount.to_i
      when < 1000
         #keep the money and sms the user

      when > 50000
         #play 50000 and refund the excess
         refund_amount = (amount.to_i - 50000)
         process_ticket(phone_number, message, 50000)


      when 1000..50000
         process_ticket(phone_number, message, amount)
      end


   end

   def process_ticket(phone_number, message, amount)
      draw_time = ((Time.now - (Time.now.min % 10).minutes).beginning_of_minute + 10.minutes).strftime("%I:%M %p")

      #check if the data is purely numbers and 3 digits long
      #if not valid send invalid sms message and generate random 3 digit code
      #if valid, then create the ticket and send confirmation sms

      #remove all spaces, leading, trailing and between spaces
      message = message.gsub(/\s+/, '')
      data = message.scan(/\d/).join('')
      if data.length > 3
         data = data[0..2]
      end
      keyword = message.gsub(/\d+/, '')

      reference = generate_ticket_reference
      network = ticket_network(gamer.phone_number)
      max_win = amount.to_i * 200

      if data.length == 3 #should also check that its below 10
         ticket = gamer.tickets.new(phone_number: gamer.phone_number, data: data, amount: amount.to_i, reference: reference, network: network, first_name: gamer.first_name, last_name: gamer.last_name, keyword: keyword)
         if ticket.save
            #Send SMS with confirmation
            message_content = "Your lucky numbers: #{data} are entered in the next draw at #{draw_time}. You could win UGX.#{max_win}! Ticket ID: #{reference}. You have been entered into the Supa Jackpot. Thank you for playing #{ENV['GAME']}"
            if SendSMS.process_sms_now(receiver: gamer.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID']) == true
               ticket.update_attributes(confirmation: true)
            end
         end

      else
         #generate random numbers
         random_data = generate_random_data
         ticket = gamer.tickets.new(phone_number: gamer.phone_number, data: random_data, amount: amount.to_i, reference: reference, network: network, first_name: gamer.first_name, last_name: gamer.last_name, keyword: keyword)
         if ticket.save
            #Send SMS with the confirmation and random number
            message_content = "We didn't recognise your numbers so we bought you a LUCKY PICK ticket #{random_data} entered in to #{draw_time} draw. You could win UGX.#{max_win}, Ticket ID: #{reference} Thank you for playing #{ENV['GAME']}."
            if SendSMS.process_sms_now(receiver: gamer.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID']) == true
               ticket.update_attributes(confirmation: true)
            end
         end
      end

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
      while (random_numbers.length != 3 || random_numbers == [1,2,3] || Draw.where("winning_number = ? AND created_at >= ?", random_numbers.join(""), Time.now-24.hours).exists?)
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
