class AnswersController < ApplicationController
  include QuizSession

  before_action :require_authentication
  before_action :initialize_quiz_session

  def show
    @photo = Photo.find(params[:quiz_id])
    @remaining_count = remaining_photos_count

    add_answered_photo(@photo.id)
  end
end
