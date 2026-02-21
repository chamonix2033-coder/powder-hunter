class PowderNotifierMailer < ApplicationMailer
  default from: ENV["GMAIL_USERNAME"] || "no-reply@powderhunter.com"

  # matching_resorts_data will be an array of hashes: [{ resort: r, date: d, index: i }]
  def powder_alert(user, matching_resorts_data)
    @user = user
    @matching_resorts_data = matching_resorts_data

    subject_text = if @matching_resorts_data.size == 1
      resort_name = @matching_resorts_data.first[:resort].name_ja.presence || @matching_resorts_data.first[:resort].name_en
      "【Powder Hunter】#{resort_name}にパウダーチャンス到来！"
    else
      "【Powder Hunter】登録した#{@matching_resorts_data.size}箇所のスキー場にパウダーチャンス到来！"
    end

    mail(
      to: @user.email,
      subject: subject_text
    )
  end
end
