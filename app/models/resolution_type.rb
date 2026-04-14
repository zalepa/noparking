class ResolutionType < ApplicationRecord
  has_many :resolutions, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :position, presence: true

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position, :name) }
end
