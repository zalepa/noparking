class Issue < ApplicationRecord
  belongs_to :user
  belongs_to :category

  has_one_attached :photo

  validates :title, length: { maximum: 120 }
  validates :latitude,  presence: true, numericality: { greater_than_or_equal_to: -90,  less_than_or_equal_to: 90 }
  validates :longitude, presence: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
  validates :notes, length: { maximum: 2_000 }
  validate  :photo_content_type
  validate  :photo_size

  scope :newest_first, -> { order(created_at: :desc) }

  # Accept a data URL ("data:image/jpeg;base64,...") captured from the client-side
  # camera and attach it as the photo. Safe no-op when the value is blank.
  def photo_data=(data_url)
    return if data_url.blank?

    match = data_url.to_s.match(/\Adata:(?<type>image\/[a-zA-Z0-9.+-]+);base64,(?<payload>.+)\z/m)
    return unless match

    content_type = match[:type]
    extension = content_type.split("/").last.sub("jpeg", "jpg")
    decoded = Base64.decode64(match[:payload])

    photo.attach(
      io: StringIO.new(decoded),
      filename: "capture-#{Time.current.to_i}.#{extension}",
      content_type: content_type
    )
  end

  private

  MAX_PHOTO_BYTES = 10.megabytes
  ALLOWED_PHOTO_TYPES = %w[image/jpeg image/jpg image/png image/webp image/heic image/heif].freeze

  def photo_content_type
    return unless photo.attached?
    unless ALLOWED_PHOTO_TYPES.include?(photo.content_type)
      errors.add(:photo, "must be a JPEG, PNG, WebP, or HEIC image")
    end
  end

  def photo_size
    return unless photo.attached?
    if photo.byte_size > MAX_PHOTO_BYTES
      errors.add(:photo, "must be smaller than #{MAX_PHOTO_BYTES / 1.megabyte} MB")
    end
  end
end
