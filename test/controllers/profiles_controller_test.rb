require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test "edit requires authentication" do
    get edit_profile_path
    assert_redirected_to new_session_path
  end

  test "edit renders for signed-in user" do
    sign_in_as @user
    get edit_profile_path
    assert_response :success
  end

  test "update with correct current password saves contact changes" do
    sign_in_as @user

    patch profile_path, params: {
      user: {
        email: @user.email,
        phone: "(555) 222-3333",
        current_password: "correct horse battery staple"
      }
    }

    assert_redirected_to edit_profile_path
    assert_equal "5552223333", @user.reload.phone
  end

  test "update with wrong current password is rejected" do
    sign_in_as @user
    original_email = @user.email

    patch profile_path, params: {
      user: {
        email: "hijacker@example.com",
        current_password: "wrong password entirely"
      }
    }

    assert_response :unprocessable_content
    assert_equal original_email, @user.reload.email
  end

  test "update rejects clearing both contact methods" do
    sign_in_as @user

    patch profile_path, params: {
      user: {
        email: "",
        phone: "",
        current_password: "correct horse battery staple"
      }
    }

    assert_response :unprocessable_content
    assert_equal users(:one).email, @user.reload.email
  end

  test "update ignores blank password fields when only changing contact info" do
    sign_in_as @user
    digest_before = @user.password_digest

    patch profile_path, params: {
      user: {
        email: @user.email,
        phone: "5559990000",
        password: "",
        password_confirmation: "",
        current_password: "correct horse battery staple"
      }
    }

    assert_redirected_to edit_profile_path
    assert_equal digest_before, @user.reload.password_digest
  end

  test "changing password invalidates other sessions but keeps current one" do
    sign_in_as @user
    other_session = @user.sessions.create!(user_agent: "other", ip_address: "10.0.0.1")

    patch profile_path, params: {
      user: {
        email: @user.email,
        password: "brand new secure passphrase",
        password_confirmation: "brand new secure passphrase",
        current_password: "correct horse battery staple"
      }
    }

    assert_redirected_to edit_profile_path
    assert_not Session.exists?(other_session.id), "other session should be destroyed"
    assert @user.reload.authenticate("brand new secure passphrase")
  end
end
