class Manager::DashboardsController < Manager::BaseController
  def show
    @stats = {
      officers:     User.enforcement.count,
      issues_total: Issue.count,
      issues_24h:   Issue.where(created_at: 24.hours.ago..).count,
      issues_7d:    Issue.where(created_at: 7.days.ago..).count
    }
    @recent_issues = Issue.includes(:category).newest_first.limit(10)

    # Latest known location per officer (within the last 24h, so stale pings
    # don't stay on the map forever). "On shift" = seen in the last 30 min.
    latest_ids = OfficerLocation
      .where(recorded_at: 24.hours.ago..)
      .group(:user_id)
      .maximum(:id)
      .values
    @officer_locations = OfficerLocation
      .where(id: latest_ids)
      .includes(:user)
      .order(recorded_at: :desc)
  end
end
