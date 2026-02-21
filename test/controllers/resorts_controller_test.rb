require "test_helper"

class ResortsControllerTest < ActionDispatch::IntegrationTest
  setup do
    stub_request(:get, /api\.open-meteo\.com/).to_return(
      status: 200,
      body: { "daily" => { "time" => [ "2026-02-21" ], "snowfall_sum" => [ 5.0 ], "temperature_2m_max" => [ -2.0 ], "temperature_2m_min" => [ -8.0 ] } }.to_json,
      headers: { "Content-Type" => "application/json" }
    )
  end

  test "should get index" do
    get resorts_url
    assert_response :success
  end
end
