rake db:create && rake db:migrate
bundle exec whenever --update-crontab && cron -f
