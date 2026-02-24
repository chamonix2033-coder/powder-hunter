class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :ski_resort

  validates :body, presence: true, length: { maximum: 256 }
  validate :validate_url_format

  private

  def validate_url_format
    return if url.blank?

    begin
      uri = URI.parse(url)
      unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
        errors.add(:url, "は http:// または https:// で始まる有効なURLを入力してください")
      end
    rescue URI::InvalidURIError
      errors.add(:url, "は有効なURL形式ではありません")
    end
  end
end
