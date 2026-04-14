class Manager::DashboardsController < Manager::BaseController
  def show
    @stats = {
      officers:     User.enforcement.count,
      issues_total: Issue.count,
      issues_24h:   Issue.where(created_at: 24.hours.ago..).count,
      issues_7d:    Issue.where(created_at: 7.days.ago..).count
    }
    @recent_issues = Issue.includes(:category).newest_first.limit(10)
  end
end
