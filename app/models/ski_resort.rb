class SkiResort < ApplicationRecord
  has_many :selections, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_one :weather_cache, dependent: :destroy

  attribute :category, :integer, default: 0
  enum :category, { resort: 0, backcountry: 1 }
end
