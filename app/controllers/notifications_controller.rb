class NotificationsController < ApplicationController
  before_action :require_authentication

  def index
    @notifications = Current.user.notifications
      .includes(:issue)
      .newest_first
      .limit(50)
  end

  def update
    notification = Current.user.notifications.find(params[:id])
    notification.mark_as_read!
    redirect_back fallback_location: issues_path
  end

  def read_all
    Current.user.notifications.unread.update_all(read_at: Time.current)
    Notification.broadcast_refresh_for(Current.user)
    redirect_back fallback_location: notifications_path
  end
end
