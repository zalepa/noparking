require "test_helper"

class Admin::DashboardsControllerTest < ActionDispatch::IntegrationTest
  test "unauthenticated users are redirected to sign in" do
    get admin_root_path
    assert_redirected_to new_session_path
  end

  test "non-admin users are redirected away with an alert" do
    sign_in_as users(:one)
    get admin_root_path
    assert_redirected_to root_path
    assert_match(/access/i, flash[:alert])
  end

  test "site admins see the dashboard" do
    sign_in_as users(:admin)
    get admin_root_path
    assert_response :success
    assert_select "h1", text: "Dashboard"
  end
end
