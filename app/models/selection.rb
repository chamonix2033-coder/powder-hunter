class Selection < ApplicationRecord
  belongs_to :user
  belongs_to :ski_resort

  validates :ski_resort_id, uniqueness: { scope: :user_id, message: "は既に選択されています" }
  validate :validate_selection_limit, on: :create

  private

  def validate_selection_limit
    if user && user.selections.count >= 3
      errors.add(:base, "スキー場は最大3つまで選択できます")
    end
  end
end
