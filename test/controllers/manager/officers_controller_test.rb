require "test_helper"

class Manager::OfficersControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:manager) }

  test "new renders the form" do
    get new_manager_officer_path
    assert_response :success
    assert_select "form[action=?]", manager_officers_path
  end

  test "edit renders the form" do
    officer = User.create!(email: "edit-officer@example.com", password: "correct horse battery staple", role: :enforcement)
    get edit_manager_officer_path(officer)
    assert_response :success
    assert_select "form[action=?]", manager_officer_path(officer)
  end

  test "creating an officer assigns the enforcement role" do
    assert_difference -> { User.enforcement.count }, 1 do
      post manager_officers_path, params: {
        user: { email: "officer@example.com", password: "correct horse battery staple", password_confirmation: "correct horse battery staple" }
      }
    end
    assert_redirected_to manager_officers_path
    assert User.find_by(email: "officer@example.com").enforcement?
  end

  test "updating without a password preserves the digest" do
    officer = User.create!(email: "keep-officer@example.com", password: "correct horse battery staple", role: :enforcement)
    original_digest = officer.password_digest
    patch manager_officer_path(officer), params: { user: { email: "keep-officer@example.com", password: "", password_confirmation: "" } }
    assert_redirected_to manager_officers_path
    assert_equal original_digest, officer.reload.password_digest
  end

  test "only enforcement role users can be edited through this controller" do
    get edit_manager_officer_path(users(:one)) # regular user
    assert_response :not_found
  end

  test "managers cannot edit other managers through this controller" do
    get edit_manager_officer_path(users(:manager))
    assert_response :not_found
  end
end
