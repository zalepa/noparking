require "test_helper"

class Admin::ManagersControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:admin) }

  test "new renders the form" do
    get new_admin_manager_path
    assert_response :success
    assert_select "form[action=?]", admin_managers_path
  end

  test "edit renders the form" do
    manager = User.create!(email: "edit-me@example.com", password: "correct horse battery staple", role: :manager)
    get edit_admin_manager_path(manager)
    assert_response :success
    assert_select "form[action=?]", admin_manager_path(manager)
  end

  test "index lists manager users" do
    User.create!(email: "mgr@example.com", password: "correct horse battery staple", role: :manager)
    get admin_managers_path
    assert_response :success
    assert_select "td", text: "mgr@example.com"
  end

  test "creating a manager assigns the manager role" do
    assert_difference -> { User.manager.count }, 1 do
      post admin_managers_path, params: {
        user: { email: "new-mgr@example.com", password: "correct horse battery staple", password_confirmation: "correct horse battery staple" }
      }
    end
    assert_redirected_to admin_managers_path
    assert User.find_by(email: "new-mgr@example.com").manager?
  end

  test "updating without a password preserves the digest" do
    manager = User.create!(email: "keep@example.com", password: "correct horse battery staple", role: :manager)
    original_digest = manager.password_digest
    patch admin_manager_path(manager), params: { user: { email: "keep@example.com", password: "", password_confirmation: "" } }
    assert_redirected_to admin_managers_path
    assert_equal original_digest, manager.reload.password_digest
  end

  test "only manager role users can be found via the controller" do
    get edit_admin_manager_path(users(:one)) # regular user, not a manager
    assert_response :not_found
  end
end
