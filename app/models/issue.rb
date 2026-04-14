class Issue < ApplicationRecord
  belongs_to :user
  belongs_to :category
  belongs_to :assigned_to, class_name: "User", optional: true
  has_one :resolution, dependent: :destroy
  has_many :notifications, dependent: :delete_all

  after_update_commit :notify_assigned, if: :saved_change_to_assigned_to_id?

  has_one_attached :photo

  validates :title, length: { maximum: 120 }
  validates :latitude,  presence: true, numericality: { greater_than_or_equal_to: -90,  less_than_or_equal_to: 90 }
  validates :longitude, presence: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
  validates :notes, length: { maximum: 2_000 }
  validate  :photo_content_type
  validate  :photo_size

  scope :newest_first, -> { order(created_at: :desc) }
  scope :unresolved, -> { where.missing(:resolution) }
  scope :open,     -> { unresolved.where(assigned_to_id: nil) }
  scope :assigned, -> { unresolved.where.not(assigned_to_id: nil) }
  scope :resolved, -> { joins(:resolution) }

  def resolved?
    resolution.present?
  end

  def assigned?
    assigned_to_id.present? && !resolved?
  end

  def state
    return :resolved if resolved?
    return :assigned if assigned_to_id.present?
    :open
  end

  EARTH_RADIUS_MILES = 3_958.8

  # Great-circle distance (Haversine) in miles between this issue and a point.
  # Returns Float::INFINITY if the issue is missing coordinates so it sorts last.
  def distance_miles_from(lat, lon)
    return Float::INFINITY if latitude.nil? || longitude.nil?
    rad = Math::PI / 180
    dlat = (latitude - lat) * rad
    dlon = (longitude - lon) * rad
    a = Math.sin(dlat / 2)**2 +
        Math.cos(lat * rad) * Math.cos(latitude * rad) * Math.sin(dlon / 2)**2
    2 * EARTH_RADIUS_MILES * Math.asin(Math.sqrt(a))
  end

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

  def notify_assigned
    return unless assigned_to_id.present?
    notifications.create!(user: user, kind: "assigned")
    Notification.broadcast_refresh_for(user)
  end

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
