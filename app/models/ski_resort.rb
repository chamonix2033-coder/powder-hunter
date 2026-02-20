class SkiResort < ApplicationRecord
  has_many :selections, dependent: :destroy
end
