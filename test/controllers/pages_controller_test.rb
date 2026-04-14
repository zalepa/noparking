require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "home renders without authentication" do
    get root_path
    assert_response :success
  end

  test "home renders for authenticated users too" do
    sign_in_as users(:one)
    get root_path
    assert_response :success
  end
end
