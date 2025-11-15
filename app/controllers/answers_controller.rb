class AnswersController < ApplicationController
  before_action :require_authentication

  def show
    @photo = Photo.find(params[:quiz_id])
  end
end
