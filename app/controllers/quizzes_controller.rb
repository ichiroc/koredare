class QuizzesController < ApplicationController
  include QuizSession

  before_action :require_authentication
  before_action :initialize_quiz_session
  before_action :redirect_to_complete_if_all_answered, only: [:index]

  def index
    photo = Photo.where.not(id: answered_photo_ids).order("RANDOM()").first

    if photo.present?
      redirect_to quiz_path(photo)
    else
      redirect_to new_photo_path, alert: "まだクイズがありません。写真をアップロードしてください。"
    end
  end

  def show
    @photo = Photo.find(params[:id])
    @remaining_count = remaining_photos_count
  end

  def complete
    redirect_to quizzes_path unless all_photos_answered?
  end

  private

  def redirect_to_complete_if_all_answered
    redirect_to complete_quizzes_path if all_photos_answered?
  end
end
