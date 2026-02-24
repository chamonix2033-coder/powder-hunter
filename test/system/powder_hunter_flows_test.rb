require "application_system_test_case"

class PowderHunterFlowsTest < ApplicationSystemTestCase
  setup do
    @user = users(:tester)
    @resort1 = ski_resorts(:resort1)
    @resort2 = ski_resorts(:resort2)
    @resort3 = ski_resorts(:resort3)
    @resort4 = ski_resorts(:resort4)

    # Stub Open-Meteo API with realistic forecast data for all batch requests
    stub_open_meteo_api
  end

  # ---------------------------------------------------------
  # Test 1: Visitor sees the landing page
  # ---------------------------------------------------------
  test "visitor can see landing page" do
    visit root_url

    assert_text "POWDER"
    assert_text "HUNTER"
    assert_text "全スキー場のパウダー情報を見る"
    assert_text "ログイン"
    assert_text "新規登録"
  end

  # ---------------------------------------------------------
  # Test 2: Signup → Logout → Login flow
  # ---------------------------------------------------------
  test "user signup and login flow" do
    # Signup
    visit new_user_registration_path
    fill_in "user[email]", with: "new_user@example.com"
    fill_in "user[password]", with: "password123"
    fill_in "user[password_confirmation]", with: "password123"
    click_button "Sign up"

    # After signup, user is logged in and redirected to resorts page
    assert_text "Powder Hunter"
    assert_text "new_user@example.com"
    assert_text "ログアウト"

    # Reset session to test login separately
    Capybara.reset_sessions!

    # Login with fixture user
    visit new_user_session_path
    fill_in "user[email]", with: @user.email
    fill_in "user[password]", with: "password123"
    click_button "Log in"

    assert_text "Powder Hunter"
    assert_text @user.email
  end

  # ---------------------------------------------------------
  # Test 3: User can select up to 3 resorts (limit enforced)
  # ---------------------------------------------------------
  test "user can select up to 3 resorts" do
    sign_in_as(@user)

    # Navigate to selection page
    click_on "表示するスキー場を編集する"
    assert_text "表示するスキー場を選ぶ"
    assert_text "現在の選択数: 0 / 3"

    # Select resorts via direct POST (button_to forms are unreliable in headless CI)
    page.driver.browser.navigate.to selections_url(ski_resort_id: @resort1.id)
    page.driver.browser.manage.add_cookie(name: "method_override", value: "post")

    # Use Capybara's built-in form submission by finding and clicking via JS
    visit selections_url
    page.execute_script("document.querySelector('[data-testid=\"selection-card-#{@resort1.id}\"] form').submit()")
    assert_text "現在の選択数: 1 / 3", wait: 10

    page.execute_script("document.querySelector('[data-testid=\"selection-card-#{@resort2.id}\"] form').submit()")
    assert_text "現在の選択数: 2 / 3", wait: 10

    page.execute_script("document.querySelector('[data-testid=\"selection-card-#{@resort3.id}\"] form').submit()")
    assert_text "現在の選択数: 3 / 3", wait: 10

    # 4th resort should show disabled button
    within("[data-testid='selection-card-#{@resort4.id}']") do
      assert_selector "button[disabled]", text: "上限（3つ）到達"
    end
  end

  # ---------------------------------------------------------
  # Test 4: Top page shows only selected resorts
  # ---------------------------------------------------------
  test "top page shows only selected resorts" do
    # Pre-create selections via fixtures/model
    Selection.create!(user: @user, ski_resort: @resort1)
    Selection.create!(user: @user, ski_resort: @resort2)

    sign_in_as(@user)

    # Top page should show only selected resorts
    assert_text @resort1.name_ja
    assert_text @resort2.name_ja
    assert_no_text @resort3.name_ja
    assert_no_text @resort4.name_ja

    # Route buttons should exist for selected resorts
    assert_selector "[data-testid='route-btn-#{@resort1.id}']"
    assert_selector "[data-testid='route-btn-#{@resort2.id}']"
  end

  # ---------------------------------------------------------
  # Test 5: User can view resort details page (14-day table)
  # ---------------------------------------------------------
  test "user can view resort details page" do
    visit resort_url(@resort1)

    assert_text @resort1.name_ja
    assert_selector "table"
    assert_text "14-Day Powder Forecast"
    assert_text "Powder Index"

    # Back to resorts list
    visit resorts_url
    assert_text "Powder Hunter"
  end

  private

  # Sign in helper
  def sign_in_as(user)
    visit new_user_session_path
    fill_in "user[email]", with: user.email
    fill_in "user[password]", with: "password123"
    click_button "Log in"
    assert_text "Powder Hunter"
  end

  # Stub the Open-Meteo batch API with realistic forecast data
  def stub_open_meteo_api
    # Generate a realistic 14-day forecast response
    today = Date.today
    dates = (0..13).map { |i| (today + i).strftime("%Y-%m-%d") }

    single_forecast = {
      "daily" => {
        "time" => dates,
        "snowfall_sum" => [ 5.0, 10.0, 0.0, 15.0, 0.0, 0.0, 2.0, 0.0, 8.0, 0.0, 0.0, 3.0, 0.0, 0.0 ],
        "temperature_2m_max" => [ -2.0, -5.0, 1.0, -8.0, 2.0, 3.0, -1.0, 0.0, -4.0, 1.0, 2.0, -2.0, 0.0, 1.0 ],
        "temperature_2m_min" => [ -8.0, -12.0, -3.0, -15.0, -2.0, -1.0, -6.0, -4.0, -10.0, -3.0, -2.0, -7.0, -4.0, -3.0 ]
      },
      "hourly" => {
        "temperature_2m" => Array.new(14 * 24, -5.0),
        "snowfall" => Array.new(14 * 24, 0.5)
      }
    }

    # Stub any request to Open-Meteo API
    # When multiple locations are sent, Open-Meteo returns an Array
    # When a single location is sent, it returns a single Hash
    stub_request(:get, /api\.open-meteo\.com\/v1\/forecast/)
      .to_return { |request|
        uri = URI(request.uri)
        params = URI.decode_www_form(uri.query).to_h
        lat_count = params["latitude"]&.split(",")&.length || 1

        if lat_count > 1
          body = Array.new(lat_count) { single_forecast }.to_json
        else
          body = single_forecast.to_json
        end

        { status: 200, body: body, headers: { "Content-Type" => "application/json" } }
      }
  end
end
