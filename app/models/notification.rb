class Notification < ApplicationRecord
  KINDS = %w[assigned released resolved].freeze

  belongs_to :user
  belongs_to :issue

  validates :kind, presence: true, inclusion: { in: KINDS }

  scope :unread,       -> { where(read_at: nil) }
  scope :newest_first, -> { order(created_at: :desc) }

  def mark_as_read!
    update!(read_at: Time.current) if read_at.nil?
    self.class.broadcast_refresh_for(user)
  end

  # Re-render the bell and list for a given user to all their subscribed tabs.
  # Called after any change (create/update/destroy) to a user's notifications.
  def self.broadcast_refresh_for(user)
    Turbo::StreamsChannel.broadcast_replace_to(
      user, :notifications,
      target: "notifications-bell",
      partial: "shared/notifications_bell",
      locals: { user: user }
    )
    Turbo::StreamsChannel.broadcast_replace_to(
      user, :notifications,
      target: "notifications-list",
      partial: "notifications/list",
      locals: { user: user }
    )
  end

  def title
    case kind
    when "assigned" then "An officer has been assigned to your report"
    when "released" then "Your report is back in the queue"
    when "resolved" then "Your report has been resolved"
    else "Update on your report"
    end
  end
end
