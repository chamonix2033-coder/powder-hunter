require "test_helper"

class SelectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:tester)
    @resort = ski_resorts(:resort1)
  end

  test "should get index when signed in" do
    sign_in @user
    get selections_url
    assert_response :success
  end

  test "should redirect index when not signed in" do
    get selections_url
    assert_response :redirect
  end
end
