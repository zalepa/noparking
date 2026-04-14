require "test_helper"

class Manager::DashboardsControllerTest < ActionDispatch::IntegrationTest
  test "unauthenticated users are redirected to sign in" do
    get manager_root_path
    assert_redirected_to new_session_path
  end

  test "non-managers are redirected away with an alert" do
    sign_in_as users(:one)
    get manager_root_path
    assert_redirected_to root_path
    assert_match(/access/i, flash[:alert])
  end

  test "site admins are also redirected — this area is for managers only" do
    sign_in_as users(:admin)
    get manager_root_path
    assert_redirected_to root_path
  end

  test "managers see the dashboard" do
    sign_in_as users(:manager)
    get manager_root_path
    assert_response :success
    assert_select "h1", text: "Dashboard"
  end
end
