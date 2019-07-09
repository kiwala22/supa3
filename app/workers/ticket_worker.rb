class TicketWorker
   include Sidekiq::Worker
   sidekiq_options retry: false
   require "send_sms"

   def perform(phone_number, data, amount)
      draw_time = ((Time.now - (Time.now.min % 10).minutes).beginning_of_minute + 10.minutes).strftime("%I:%M %p")
      #Check if gamer exists or create and return gamer
      gamer = Gamer.find_or_create_by(phone_number: phone_number)

      #check if the data is purely numbers and 3 digits long
      #if not valid send invalid sms message and generate random 3 digit code
      #if valid, then create the ticket and send confirmation sms
      reference = generate_ticket_reference
      if data.split(" ").map(&:to_i).all?{|f| f.is_a?(Integer)} && data.split(" ").map(&:to_i).length == 5
         ticket = gamer.tickets.new(phone_number: gamer.phone_number, data: data.gsub(" ", ","), amount: amount.to_i, reference: reference)
         if ticket.save
            #Send SMS with confirmation
            message_content = "Thank you for playing #{ENV['GAME']}. You have played #{data.gsub(" ", ",")} entered in to #{draw_time} draw. Ticket: #{reference}"
            #SendSMS.process_sms_now(receiver: gamer.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])
         end

      else
         #generate random numbers
         random_data = generate_random_data
         ticket = gamer.tickets.new(phone_number: gamer.phone_number, data: random_data, amount: amount.to_i, reference: reference)
         if ticket.save
            #Send SMS with the confirmation and random number
            message_content = "Thank you for playing #{ENV['GAME']}. Input was incorrect and we have picked #{random_data} for you entered in to #{draw_time} draw. Ticket: #{reference}"
            #SendSMS.process_sms_now(receiver: gamer.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])
         end
      end

   end

   def generate_random_data()
      random_numbers = []
      while random_numbers.length != 5
           random_numbers = SecureRandom.hex(50).split("").uniq.map(&:hex).sample(5).join(",").split(",").map(&:to_i)
      end
      return random_numbers.join(",")
   end

   def generate_ticket_reference
      begin
         ref = rand(36**8).to_s(36).upcase
      end while Ticket.where(reference: ref).exists?
      return ref
   end


end
