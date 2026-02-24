class SkiResort < ApplicationRecord
  has_many :selections, dependent: :destroy
  has_many :comments, dependent: :destroy
end
