class Admins::SessionsController < ApplicationController
  ADMIN_PASSWORD = "seto-admin"

  def new
  end

  def create
    if params[:password] == ADMIN_PASSWORD
      session[:admin_authenticated] = true
      redirect_to admins_root_path, notice: "管理画面にログインしました"
    else
      flash.now[:alert] = "パスワードが違います"
      render :new, status: :unprocessable_entity
    end
  end
end
