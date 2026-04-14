require "test_helper"

class Officer::DashboardsControllerTest < ActionDispatch::IntegrationTest
  test "non-officers cannot access" do
    sign_in_as users(:one)
    get officer_root_path
    assert_redirected_to root_path
  end

  test "officer sees dashboard" do
    sign_in_as users(:officer)
    get officer_root_path
    assert_response :success
    assert_select "h1", text: "Nearby reports"
  end

  test "with coordinates, issues are sorted by distance" do
    sign_in_as users(:officer)
    near = Issue.create!(user: users(:one), category: categories(:crosswalk),
                         title: "Near me", latitude: 40.7130, longitude: -74.0060)
    far  = Issue.create!(user: users(:one), category: categories(:crosswalk),
                         title: "Far away",  latitude: 34.0522, longitude: -118.2437) # LA

    get officer_root_path(lat: 40.7128, lng: -74.0060)
    assert_response :success

    assigns_issues = @controller.instance_variable_get(:@issues)
    assert_equal [ near.id, far.id ], assigns_issues.map(&:id)
  end
end
