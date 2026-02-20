class PowderNotifierMailer < ApplicationMailer
  default from: ENV['GMAIL_USERNAME'] || 'no-reply@powderhunter.com'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.powder_notifier_mailer.powder_alert.subject
  #
  def powder_alert(user, resort, powder_date, index_val)
    @user = user
    @resort = resort
    @powder_date = powder_date
    @index_val = index_val

    resort_name = @resort.name_ja.presence || @resort.name_en
    mail(
      to: @user.email,
      subject: "【Powder Hunter】#{resort_name}にパウダーチャンス到来！（#{@powder_date}）"
    )
  end
end
