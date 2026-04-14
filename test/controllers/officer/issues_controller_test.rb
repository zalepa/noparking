require "test_helper"

class Officer::IssuesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:officer) }

  test "index renders all issues newest-first when no coordinates" do
    older  = Issue.create!(user: users(:one), category: categories(:crosswalk),
                          title: "Older", latitude: 40.0, longitude: -74.0, created_at: 2.days.ago)
    newer = Issue.create!(user: users(:one), category: categories(:crosswalk),
                          title: "Newer", latitude: 40.0, longitude: -74.0, created_at: 1.hour.ago)

    get officer_issues_path
    assert_response :success
    issues = @controller.instance_variable_get(:@issues)
    assert_equal [ newer.id, older.id ], issues.first(2).map(&:id)
  end

  test "show renders a single issue" do
    issue = Issue.create!(user: users(:one), category: categories(:crosswalk),
                          title: "Report", latitude: 40.0, longitude: -74.0)
    get officer_issue_path(issue)
    assert_response :success
    assert_select "h1", text: "Report"
  end
end
