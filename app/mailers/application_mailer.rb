class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("GMAIL_USERNAME", "no-reply@powderhunter.com")
  layout "mailer"
end
