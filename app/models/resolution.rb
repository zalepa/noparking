class Resolution < ApplicationRecord
  belongs_to :issue
  belongs_to :resolution_type
  belongs_to :user

  validates :note, length: { maximum: 2_000 }
  validates :citation_number, length: { maximum: 120 }
end
