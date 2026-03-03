require "application_system_test_case"

class CommentFlowsTest < ApplicationSystemTestCase
  setup do
    @user = users(:tester)
    @resort1 = ski_resorts(:resort1)

    # Stub Open-Meteo API
    stub_open_meteo_api
  end

  # ---------------------------------------------------------
  # Test 1: 未ログインユーザーはコメント一覧を閲覧でき、投稿フォームは非表示
  # ---------------------------------------------------------
  test "visitor can see comments but not post form" do
    # 事前にコメントを作成
    comment = Comment.create!(user: @user, ski_resort: @resort1, body: "素晴らしいパウダーでした！", url: "https://example.com/report")

    visit resort_url(@resort1)

    # コメント一覧が表示される
    assert_text "💬 コメント"
    assert_text "素晴らしいパウダーでした！"
    assert_selector "a[href='https://example.com/report'][target='_blank']"

    # 投稿フォームは非表示
    assert_no_text "コメントを投稿する"
    assert_text "ログインするとコメントを投稿できます"
  end

  # ---------------------------------------------------------
  # Test 2: ログインユーザーがコメントを投稿できる
  # ---------------------------------------------------------
  test "logged in user can post a comment" do
    sign_in_as(@user)
    visit resort_url(@resort1)

    assert_text "コメントを投稿する"

    fill_in "comment[body]", with: "今日の雪質は最高でした！"
    fill_in "comment[url]", with: "https://example.com/snow-report"
    click_button "投稿する"

    assert_text "コメントを投稿しました"
    assert_text "今日の雪質は最高でした！"
    assert_selector "a[href='https://example.com/snow-report'][target='_blank']"
  end

  # ---------------------------------------------------------
  # Test 3: ログインユーザーが自分のコメントを編集できる
  # ---------------------------------------------------------
  test "logged in user can edit own comment" do
    comment = Comment.create!(user: @user, ski_resort: @resort1, body: "元のコメント", url: "https://old.example.com")

    sign_in_as(@user)
    visit resort_url(@resort1)

    assert_text "元のコメント"

    # 編集ボタンをクリック
    within("#comment-#{comment.id}") do
      click_button "✏️ 編集"
    end

    # 編集フォーム内で入力（表示されるまで待つ）
    assert_selector "[data-edit-for='#{comment.id}']", visible: true

    within("[data-edit-for='#{comment.id}']") do
      fill_in "comment_body_edit_#{comment.id}", with: "編集後のコメントです"
      fill_in "comment_url_edit_#{comment.id}", with: "https://new.example.com"
      click_button "更新"
    end

    assert_text "コメントを更新しました"
    assert_text "編集後のコメントです"
    assert_selector "a[href='https://new.example.com'][target='_blank']"
  end

  # ---------------------------------------------------------
  # Test 4: ログインユーザーが自分のコメントを削除できる
  # ---------------------------------------------------------
  test "logged in user can delete own comment" do
    comment = Comment.create!(user: @user, ski_resort: @resort1, body: "削除予定のコメント")

    sign_in_as(@user)
    visit resort_url(@resort1)

    assert_text "削除予定のコメント"

    # Turbo + Chrome の組み合わせで accept_confirm が不安定なため
    # window.confirm を常に true を返すよう上書きしてダイアログをスキップ
    page.execute_script("window.confirm = function() { return true; }")

    within("#comment-#{comment.id}") do
      click_button "🗑️ 削除"
    end

    assert_text "コメントを削除しました"
    assert_no_text "削除予定のコメント"
  end

  # ---------------------------------------------------------
  # Test 5: 256文字超のコメントはバリデーションエラーになる
  # ---------------------------------------------------------
  test "comment body exceeding 256 chars shows validation error" do
    sign_in_as(@user)
    visit resort_url(@resort1)

    long_body = "あ" * 257
    # maxlength除去・値セット・フォーム送信をJSで一括実行
    # click_button経由だとChrome145でJS設定値がフォームに含まれない問題があるため
    # requestSubmit() でフォームイベントを正しく発火させて送信する
    page.execute_script(<<~JS)
      (function() {
        var el = document.querySelector('#comment_body');
        el.removeAttribute('maxlength');
        el.value = #{long_body.to_json};
        el.form.requestSubmit();
      })();
    JS

    assert_text "too long"
  end

  private

  def sign_in_as(user)
    visit new_user_session_path
    fill_in "user[email]", with: user.email
    fill_in "user[password]", with: "password123"
    click_button "Log in"
    assert_text "Powder Hunter"
  end

  def stub_open_meteo_api
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
