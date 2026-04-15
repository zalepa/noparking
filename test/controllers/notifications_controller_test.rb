require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as @user
    @issue = Issue.create!(user: @user, category: categories(:crosswalk),
                           title: "Report", latitude: 40.0, longitude: -74.0)
    @notification = @user.notifications.create!(issue: @issue, kind: "assigned")
  end

  test "index lists notifications" do
    get notifications_path
    assert_response :success
    assert_select "body", text: /An officer has been assigned/
  end

  test "update marks a notification read" do
    patch notification_path(@notification)
    assert_not_nil @notification.reload.read_at
  end

  test "read_all marks all notifications read" do
    extra = @user.notifications.create!(issue: @issue, kind: "resolved")
    post read_all_notifications_path
    assert_not_nil @notification.reload.read_at
    assert_not_nil extra.reload.read_at
  end

  test "cannot see another user's notifications" do
    other = users(:two)
    other_issue = Issue.create!(user: other, category: categories(:crosswalk),
                                title: "Other", latitude: 40.0, longitude: -74.0)
    other_notification = other.notifications.create!(issue: other_issue, kind: "resolved")
    patch notification_path(other_notification)
    assert_response :not_found
    assert_nil other_notification.reload.read_at
  end

  test "resolving an issue creates a notification for the reporter" do
    @issue.update!(assigned_to: users(:officer), assigned_at: Time.current)
    assert_difference -> { @user.notifications.where(kind: "resolved").count }, 1 do
      @issue.create_resolution!(user: users(:officer), resolution_type: resolution_types(:summons))
    end
  end

  test "an officer claiming an issue creates a notification for the reporter" do
    sign_in_as users(:officer)
    assert_difference -> { @user.notifications.where(kind: "assigned").count }, 1 do
      post officer_issue_assignment_path(@issue)
    end
  end

  test "an officer releasing an issue creates a notification for the reporter" do
    @issue.update!(assigned_to: users(:officer), assigned_at: Time.current)
    sign_in_as users(:officer)
    assert_difference -> { @user.notifications.where(kind: "released").count }, 1 do
      delete officer_issue_assignment_path(@issue)
    end
  end
end
