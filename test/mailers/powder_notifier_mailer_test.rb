require "test_helper"

class PowderNotifierMailerTest < ActionMailer::TestCase
  test "powder_alert" do
    mail = PowderNotifierMailer.powder_alert
    assert_equal "Powder alert", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
