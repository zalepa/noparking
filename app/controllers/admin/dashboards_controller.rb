class Admin::DashboardsController < Admin::BaseController
  def show
    @stats = {
      residents:    User.regular.count,
      enforcement:  User.enforcement.count,
      managers:     User.manager.count,
      site_admins:  User.site_admin.count,
      categories:   Category.count,
      issues_total: Issue.count,
      issues_24h:   Issue.where(created_at: 24.hours.ago..).count,
      issues_7d:    Issue.where(created_at: 7.days.ago..).count
    }
    @recent_issues = Issue.includes(:category).newest_first.limit(10)
  end
end
