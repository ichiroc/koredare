class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def require_authentication
    unless session[:authenticated]
      redirect_to new_session_path, alert: "パスワードを入力してください"
    end
  end

  def require_admin_authentication
    unless session[:admin_authenticated]
      redirect_to new_admins_session_path, alert: "管理画面のパスワードを入力してください"
    end
  end
end
