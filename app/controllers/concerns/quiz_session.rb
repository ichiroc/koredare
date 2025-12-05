module QuizSession
  extend ActiveSupport::Concern

  private

  def initialize_quiz_session
    session[:answered_photo_ids] ||= []
  end

  def answered_photo_ids
    session[:answered_photo_ids] || []
  end

  def add_answered_photo(photo_id)
    initialize_quiz_session
    session[:answered_photo_ids] << photo_id unless session[:answered_photo_ids].include?(photo_id)
  end

  def remaining_photos_count
    Photo.where.not(id: answered_photo_ids).count
  end

  def all_photos_answered?
    remaining_photos_count.zero? && Photo.exists?
  end

  def reset_quiz_session
    session.delete(:answered_photo_ids)
  end
end
