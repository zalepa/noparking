class Resolution < ApplicationRecord
  belongs_to :issue
  belongs_to :resolution_type
  belongs_to :user

  validates :note, length: { maximum: 2_000 }
  validates :citation_number, length: { maximum: 120 }

  after_create_commit :notify_reporter

  private

  def notify_reporter
    issue.notifications.create!(user: issue.user, kind: "resolved")
    Notification.broadcast_refresh_for(issue.user)
  end
end
