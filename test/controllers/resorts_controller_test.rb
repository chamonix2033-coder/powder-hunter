require "test_helper"

class ResortsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get resorts_index_url
    assert_response :success
  end
end
