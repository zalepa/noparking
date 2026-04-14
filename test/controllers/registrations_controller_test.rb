require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new" do
    get new_registration_path
    assert_response :success
  end

  test "authenticated user is redirected away from new" do
    sign_in_as users(:one)
    get new_registration_path
    assert_redirected_to issues_path
  end

  test "create with email signs the user in and redirects to issues" do
    assert_difference -> { User.count }, +1 do
      post registration_path, params: {
        user: {
          contact_method: "email",
          email: "new-user@example.com",
          password: "correct horse battery staple",
          password_confirmation: "correct horse battery staple"
        }
      }
    end

    assert_redirected_to issues_path
    assert cookies[:session_id]
    assert_equal "new-user@example.com", User.last.email
    assert_nil User.last.phone
  end

  test "create with phone normalizes the value" do
    assert_difference -> { User.count }, +1 do
      post registration_path, params: {
        user: {
          contact_method: "phone",
          phone: "(555) 867-5309",
          password: "correct horse battery staple",
          password_confirmation: "correct horse battery staple"
        }
      }
    end

    user = User.last
    assert_equal "5558675309", user.phone
    assert_nil user.email
    assert_redirected_to issues_path
  end

  test "create ignores the inactive contact field for the selected method" do
    # User selects 'phone' but the email field also has a value (stale from toggle).
    # Only the phone should be persisted.
    post registration_path, params: {
      user: {
        contact_method: "phone",
        email: "should-not-be-saved@example.com",
        phone: "5557778888",
        password: "correct horse battery staple",
        password_confirmation: "correct horse battery staple"
      }
    }

    user = User.last
    assert_equal "5557778888", user.phone
    assert_nil user.email
  end

  test "create with short password re-renders with error" do
    assert_no_difference -> { User.count } do
      post registration_path, params: {
        user: {
          contact_method: "email",
          email: "shortpw@example.com",
          password: "too short",
          password_confirmation: "too short"
        }
      }
    end

    assert_response :unprocessable_content
    assert_select "div", /12 characters/
  end

  test "create with mismatched passwords re-renders with error" do
    assert_no_difference -> { User.count } do
      post registration_path, params: {
        user: {
          contact_method: "email",
          email: "mismatch@example.com",
          password: "correct horse battery staple",
          password_confirmation: "wrong confirmation entirely"
        }
      }
    end

    assert_response :unprocessable_content
  end

  test "create with duplicate email re-renders with error" do
    assert_no_difference -> { User.count } do
      post registration_path, params: {
        user: {
          contact_method: "email",
          email: users(:one).email,
          password: "correct horse battery staple",
          password_confirmation: "correct horse battery staple"
        }
      }
    end

    assert_response :unprocessable_content
    assert_select "div", /has already been taken/
  end
end
