require "test_helper"

class Officer::AssignmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @officer = users(:officer)
    @issue = Issue.create!(user: users(:one), category: categories(:crosswalk),
                           title: "Report", latitude: 40.0, longitude: -74.0)
  end

  test "create assigns an unassigned issue to the current officer" do
    sign_in_as @officer
    post officer_issue_assignment_path(@issue)
    assert_redirected_to officer_issue_path(@issue)
    @issue.reload
    assert_equal @officer.id, @issue.assigned_to_id
    assert_not_nil @issue.assigned_at
    assert @issue.assigned?
  end

  test "create does not overwrite an existing assignment" do
    other = User.create!(email: "other-officer@example.com", password: "aVerySecret123!", role: :enforcement)
    @issue.update!(assigned_to: other, assigned_at: 5.minutes.ago)

    sign_in_as @officer
    post officer_issue_assignment_path(@issue)
    @issue.reload
    assert_equal other.id, @issue.assigned_to_id
    assert_redirected_to officer_issue_path(@issue)
    follow_redirect!
    assert_match(/already assigned/i, flash[:alert] || "")
  end

  test "destroy releases only the assignee's own claim" do
    sign_in_as @officer
    @issue.update!(assigned_to: @officer, assigned_at: Time.current)

    delete officer_issue_assignment_path(@issue)
    @issue.reload
    assert_nil @issue.assigned_to_id
    assert_nil @issue.assigned_at
  end

  test "destroy rejects release by a non-assignee" do
    other = User.create!(email: "other-officer2@example.com", password: "aVerySecret123!", role: :enforcement)
    @issue.update!(assigned_to: other, assigned_at: Time.current)

    sign_in_as @officer
    delete officer_issue_assignment_path(@issue)
    @issue.reload
    assert_equal other.id, @issue.assigned_to_id
  end

  test "non-officers cannot assign" do
    sign_in_as users(:one)
    post officer_issue_assignment_path(@issue)
    assert_response :redirect
    @issue.reload
    assert_nil @issue.assigned_to_id
  end
end
