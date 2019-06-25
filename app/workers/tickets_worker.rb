class TicketsWorker
   include Sidekiq::Worker
   require "send_sms"

   def perform(*args)
      #extract the parameters
      phone_number = args[:phone_number]
      amount = args[:amount]
      data = args[:data]

      #Check if gamer exists or create and return gamer
      gamer = Gamer.find_or_create_by(phone_number: phone_number)

      #check if the data is purely numbers and 3 digits long
      #if not valid send invalid sms message and generate random 3 digit code
      #if valid, then create the ticket and send confirmation sms

      if /^\d{3}$/ === data
         ticket = gamer.tickets.new(phone_number: gamer.phone_number, reference: data, amount: amount.to_i)
         if ticket.save
            #Send SMS with confirmation
            message_content = ""
            SendSMS.process_sms_now(receiver: gamer.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])
         end

      else
         #generate random numbers
         random_ref = generate_random_data
         ticket = gamer.tickets.new(phone_number: gamer.phone_number, reference: random_ref, amount: amount.to_i)
         if ticket.save
            #Send SMS with the confirmation and random number
            message_content = ""
            SendSMS.process_sms_now(receiver: gamer.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])
         end
      end

   end

   def generate_random_data()
      arr = []
      while arr.length < 3
        arr << rand(0..9)
        arr.uniq!
     end
     return arr.join("")
   end

   def generate_ticket_reference

   end


end


#create another column instead of reference to store the played numbers
