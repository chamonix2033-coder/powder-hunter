# Preview all emails at http://localhost:3000/rails/mailers/powder_notifier_mailer
class PowderNotifierMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/powder_notifier_mailer/powder_alert
  def powder_alert
    PowderNotifierMailer.powder_alert
  end
end
