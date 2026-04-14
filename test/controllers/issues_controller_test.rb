require "test_helper"

class IssuesControllerTest < ActionDispatch::IntegrationTest
  test "index redirects unauthenticated users to sign in" do
    get issues_path
    assert_redirected_to new_session_path
  end

  test "index renders for authenticated users" do
    sign_in_as users(:one)
    get issues_path
    assert_response :success
    assert_select "h1", text: /My Issues/
  end
end
