class UpdateResultsWorker
  include Sidekiq::Worker
  sidekiq_options queue: "high"
  sidekiq_options retry: false

  def perform
    results = CSV.read("/tmp/results_supa3.csv")

    results_arr = []
    results.each do |result|
      results_arr << {phone_number: result[0], matches: result[1], time: result[2]}
    end

    results_arr.each do |t|
      Result.create(phone_number: t[:phone_number], matches: t[:amount], time: t[:time])
    end
  end
end
