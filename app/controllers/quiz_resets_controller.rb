class QuizResetsController < ApplicationController
  include QuizSession

  before_action :require_authentication

  def create
    reset_quiz_session
    redirect_to quizzes_path, notice: "クイズをリセットしました"
  end
end
