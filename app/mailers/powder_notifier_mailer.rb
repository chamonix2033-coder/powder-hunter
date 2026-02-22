class PowderNotifierMailer < ApplicationMailer
  default from: ENV["GMAIL_USERNAME"] || "no-reply@powderhunter.com"

  # matching_resorts_data will be an array of hashes:
  # [{ resort: r, date: d, index: i, reason: :new/:earlier/:later, last_date_str: "X月Y日" }]
  def powder_alert(user, matching_resorts_data)
    @user = user
    @matching_resorts_data = matching_resorts_data

    # Determine subject based on the most important reason
    reasons = matching_resorts_data.map { |d| d[:reason] }
    subject_text = if reasons.include?(:new)
      build_subject_for_reason(:new, matching_resorts_data)
    elsif reasons.include?(:earlier)
      build_subject_for_reason(:earlier, matching_resorts_data)
    else
      build_subject_for_reason(:later, matching_resorts_data)
    end

    mail(
      to: @user.email,
      subject: subject_text
    )
  end

  private

  def build_subject_for_reason(primary_reason, data)
    case primary_reason
    when :new
      if data.size == 1
        resort_name = data.first[:resort].name_ja.presence || data.first[:resort].name_en
        "【Powder Hunter】#{resort_name}にパウダーチャンス到来！"
      else
        "【Powder Hunter】登録した#{data.size}箇所のスキー場にパウダー情報更新！"
      end
    when :earlier
      "【Powder Hunter】パウダーチャンス日が早まりました！"
    when :later
      "【Powder Hunter】パウダーチャンス日が遅れそうです！"
    end
  end
end
