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

# FIXME: change this to be each 55 minutes. (to make sure it's peresisted before 1 hour)

ENV.each_key do |key|
  env key.to_sym, ENV[key]
end

every 55.minute do
  rake 'update_counts:messages'
  rake 'update_counts:chats'
end
