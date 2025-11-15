class Admins::PhotosController < ApplicationController
  before_action :require_admin_authentication

  def index
    @photos = Photo.order(created_at: :desc)
  end
end
