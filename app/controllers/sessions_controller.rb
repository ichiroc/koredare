class SessionsController < ApplicationController
  QUIZ_PASSWORD = "seto-gasshuku-10"

  def new
  end

  def create
    if params[:password] == QUIZ_PASSWORD
      session[:authenticated] = true
      redirect_to quizzes_path, notice: "ログインしました"
    else
      flash.now[:alert] = "パスワードが違います"
      render :new, status: :unprocessable_entity
    end
  end
end
