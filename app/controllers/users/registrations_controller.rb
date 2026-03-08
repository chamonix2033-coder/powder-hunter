class Users::RegistrationsController < Devise::RegistrationsController
  protected

  def update_resource(resource, params)
    # パスワードを変更しようとしている場合のみ、現在のパスワード入力を要求する
    if params[:password].present? || params[:password_confirmation].present?
      resource.update_with_password(params)
    else
      # メール通知の変更や、単なるパスワード以外の変更の場合は
      # 現在のパスワードなしで更新を許可する
      params.delete(:current_password)
      resource.update_without_password(params)
    end
  end
end
