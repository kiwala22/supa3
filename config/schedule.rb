# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

every 1.minute do
  runner "Broadcast.process_broadcasts"
end

every 1.day, at: '00:05 am' do
  runner "Gamer.run_predictions"
end

every 1.day, at: '08:05 am' do
  runner "Segment.update_segments"
end

every '0,10,20,30,40,50 * * * *' do
  runner "Ticket.run_draws"
end
