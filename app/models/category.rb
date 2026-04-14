class Category < ApplicationRecord
  has_many :issues, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :position, presence: true

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position, :name) }
end
