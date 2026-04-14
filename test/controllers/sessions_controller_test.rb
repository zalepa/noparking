require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test "new" do
    get new_session_path
    assert_response :success
  end

  test "create with valid email and password redirects to issues" do
    post session_path, params: { login: @user.email, password: "correct horse battery staple" }

    assert_redirected_to issues_path
    assert cookies[:session_id]
  end

  test "create with valid phone in any format" do
    user = users(:phone_only)
    post session_path, params: { login: "(555) 111-2222", password: "correct horse battery staple" }

    assert_redirected_to issues_path
    assert cookies[:session_id]
  end

  test "create with invalid credentials does not sign in" do
    post session_path, params: { login: @user.email, password: "wrong password here" }

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "create with unknown identifier does not sign in" do
    post session_path, params: { login: "nobody@example.com", password: "correct horse battery staple" }

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "authenticated user visiting new is sent to issues" do
    sign_in_as @user
    get new_session_path
    assert_redirected_to issues_path
  end

  test "destroy signs the user out and redirects home" do
    sign_in_as @user

    delete session_path

    assert_redirected_to root_path
    assert_empty cookies[:session_id]
  end
end
