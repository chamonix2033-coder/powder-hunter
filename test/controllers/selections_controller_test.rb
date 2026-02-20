require "test_helper"

class SelectionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get selections_index_url
    assert_response :success
  end

  test "should get create" do
    get selections_create_url
    assert_response :success
  end

  test "should get destroy" do
    get selections_destroy_url
    assert_response :success
  end
end
