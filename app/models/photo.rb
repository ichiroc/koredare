class Photo < ApplicationRecord
  has_one_attached :image

  validates :name, presence: true
  validates :image, presence: true

  def self.random
    order("RANDOM()").first
  end
end
