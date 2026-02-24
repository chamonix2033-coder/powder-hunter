class PowderNotifierMailerPreview < ActionMailer::Preview
  # 🆕 新規パウダーチャンス到来メール
  # http://localhost:3000/rails/mailers/powder_notifier_mailer/powder_alert_new
  def powder_alert_new
    user = User.first || User.new(email: "test@example.com")
    resort = SkiResort.first || SkiResort.new(name_ja: "テストスキー場", name_en: "Test Resort")
    data = [
      { resort: resort, date: "2月25日", index: 60, reason: :new, last_date_str: nil }
    ]
    PowderNotifierMailer.powder_alert(user, data)
  end

  # ⏩ パウダーチャンス日が早まったメール
  # http://localhost:3000/rails/mailers/powder_notifier_mailer/powder_alert_earlier
  def powder_alert_earlier
    user = User.first || User.new(email: "test@example.com")
    resort = SkiResort.first || SkiResort.new(name_ja: "テストスキー場", name_en: "Test Resort")
    data = [
      { resort: resort, date: "2月23日", index: 75, reason: :earlier, last_date_str: "2月27日" }
    ]
    PowderNotifierMailer.powder_alert(user, data)
  end

  # ⏪ パウダーチャンス日が遅れたメール
  # http://localhost:3000/rails/mailers/powder_notifier_mailer/powder_alert_later
  def powder_alert_later
    user = User.first || User.new(email: "test@example.com")
    resort = SkiResort.first || SkiResort.new(name_ja: "テストスキー場", name_en: "Test Resort")
    data = [
      { resort: resort, date: "3月1日", index: 45, reason: :later, last_date_str: "2月25日" }
    ]
    PowderNotifierMailer.powder_alert(user, data)
  end
end
