class PromotionalSmsWorker
  include Sidekiq::Worker

  sidekiq_options queue: "default"

  def perform

    # Check all predictions with a target greater than zero (0)
    Prediction.select(:id, :gamer_id, :target).where("target > ?", 0).find_each(batch_size: 5000) do |prediction|
      process_promotions(prediction.gamer_id, prediction.target)
    end

  end

  def process_promotions(gamer_id, target)
    gamer = Gamer.find(gamer_id)

    phone_number = gamer.phone_number
    sender_id = ENV['DEFAULT_SENDER_ID']

    message_content = "Play a total of #{target} tickets this week and win a bonus of 20% your total amount played. Thank you for playing #{ENV['GAME']}"

    if !gamer.first_name.nil?
      message = gamer.first_name + ", " + message_content
    else
      message = "Hi, " + message_content
    end

    SmsWorker.perform_async(phone_number, message, sender_id)

  end
end
