require "test_helper"

class PowderNotifierMailerTest < ActionMailer::TestCase
  test "powder_alert" do
    user = users(:tester)
    resort = ski_resorts(:resort1)
    matching_data = [ { resort: resort, date: "2月21日", index: 60, reason: :new, last_date_str: nil } ]

    mail = PowderNotifierMailer.powder_alert(user, matching_data)
    assert_equal [ user.email ], mail.to
    assert_match "Powder Hunter", mail.subject
  end
end
