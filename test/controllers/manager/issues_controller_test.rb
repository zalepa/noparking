require "test_helper"

class Manager::IssuesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:manager) }

  test "index renders all issues across users" do
    Issue.create!(user: users(:one), category: categories(:crosswalk),
                  title: "Resident report", latitude: 40.0, longitude: -74.0)
    get manager_issues_path
    assert_response :success
    assert_select "h2", text: "Resident report"
  end

  test "index filters by category" do
    Issue.create!(user: users(:one), category: categories(:crosswalk),
                  title: "In crosswalk", latitude: 40.0, longitude: -74.0)
    Issue.create!(user: users(:one), category: categories(:hydrant),
                  title: "At hydrant", latitude: 40.0, longitude: -74.0)
    get manager_issues_path(category_id: categories(:crosswalk).id)
    assert_response :success
    assert_select "h2", text: "In crosswalk"
    assert_select "h2", text: "At hydrant", count: 0
  end

  test "show renders a single issue" do
    issue = Issue.create!(user: users(:one), category: categories(:crosswalk),
                          title: "Detail check", latitude: 40.0, longitude: -74.0)
    get manager_issue_path(issue)
    assert_response :success
    assert_select "h1", text: "Detail check"
  end
end
