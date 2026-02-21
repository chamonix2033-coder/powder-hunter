# Use this file to easily define all of your cron jobs.

env :PATH, ENV["PATH"]
set :output, "log/cron.log"

every 1.day, at: "8:00 am" do
  rake "powder:check"
end
