class SkiResort < ApplicationRecord
  has_many :selections, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_one :weather_cache, dependent: :destroy
end
