class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_account_update_params, only: [ :update ]

  protected

  def configure_account_update_params
    # account_update アクション時に email_notifications を許可する
    devise_parameter_sanitizer.permit(:account_update, keys: [ :email_notifications ])
  end

  def update_resource(resource, params)
    if params[:password].present? || params[:password_confirmation].present?
      # パスワード変更がある場合は Devise 標準のパスワード確認付き更新
      resource.update_with_password(params)
    else
      # パスワード変更がない場合、パスワード関連と current_password を除外して直接 update を呼ぶ
      # これにより validation エラー（Password can't be blank）を回避し、
      # かつ Devise の独自フィルターを回避して email_notifications を確実に保存する
      params.delete(:password)
      params.delete(:password_confirmation)
      params.delete(:current_password)
      resource.update(params)
    end
  end
end
