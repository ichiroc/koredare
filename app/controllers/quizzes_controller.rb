class QuizzesController < ApplicationController
  before_action :require_authentication

  def index
    photo = Photo.order("RANDOM()").first
    if photo
      redirect_to quiz_path(photo)
    else
      redirect_to new_photo_path, alert: "まだクイズがありません。写真をアップロードしてください。"
    end
  end

  def show
    @photo = Photo.find(params[:id])
  end
end
