require "application_system_test_case"

class PowderHunterFlowsTest < ApplicationSystemTestCase
  setup do
    @user = users(:tester)
    @resort1 = ski_resorts(:resort1)
    @resort2 = ski_resorts(:resort2)
    @resort3 = ski_resorts(:resort3)
    @resort4 = ski_resorts(:resort4)
  end

  test "full user flow: signup, login, select resorts, limit, weather, details, route, logout" do
    # 1. Signup / Login / Logout
    visit root_url

    click_on "新規登録"
    fill_in "user[email]", with: "new_user@example.com"
    fill_in "user[password]", with: "password123"
    fill_in "user[password_confirmation]", with: "password123"
    click_button "Sign up"

    assert_text "Welcome! You have signed up successfully."
    
    click_on "ログアウト"
    assert_text "Signed out successfully."
    assert_text "Powder Hunter"

    click_on "ログイン"
    fill_in "user[email]", with: @user.email
    fill_in "user[password]", with: "password123"
    click_button "Log in"

    assert_text "Signed in successfully."

    # 2. Select Resorts
    # Currently 0 selections
    assert_text "まだスキー場が選択されていません"
    
    click_on "こちらからスキー場を最大3つ選んでください"
    
    assert_text "表示するスキー場を選ぶ"
    assert_text "現在の選択数: 0 / 3"

    # Pick 3
    select_resort(@resort1)
    assert_text "スキー場を選択しました"
    assert_text "現在の選択数: 1 / 3"

    select_resort(@resort2)
    assert_text "スキー場を選択しました"
    assert_text "現在の選択数: 2 / 3"

    select_resort(@resort3)
    assert_text "スキー場を選択しました"
    assert_text "現在の選択数: 3 / 3"

    # 4th should be disabled
    node4 = find('h3', text: @resort4.name_ja).find(:xpath, 'ancestor::div[contains(@style, "background-color: white")][1]')
    within node4 do
      assert_button "上限（3つ）到達", disabled: true
    end

    # Go back to top page
    click_on "トップページへ戻る"

    # 3. Weather API & Index Display on Top Page
    assert_text @resort1.name_ja
    assert_text @resort2.name_ja
    assert_text @resort3.name_ja
    assert_no_text @resort4.name_ja

    # Check for index
    assert_text "Powder Index:"
    
    # 5. Route Search (Verify button presence)
    assert_selector "button.route-btn", text: "ここへのルートを表示", count: 3
    first_btn = first("button.route-btn")
    assert_not_nil first_btn['data-lat']
    assert_not_nil first_btn['data-lon']

    # 4. Details Page
    click_on @resort1.name_ja
    assert_text @resort1.name_en
    assert_selector "table"
    assert_text "14日間"
  end

  private

  def select_resort(resort)
    node = find('h3', text: resort.name_ja).find(:xpath, 'ancestor::div[contains(@style, "background-color: white")][1]')
    within node do
      click_on "トップに表示"
    end
  end
end
