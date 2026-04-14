require "test_helper"

class Officer::LocationsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:officer) }

  test "create records a location for the current officer" do
    assert_difference -> { users(:officer).officer_locations.count }, 1 do
      post officer_locations_path, params: { latitude: 40.1, longitude: -74.2, accuracy_meters: 15 }
    end
    assert_response :no_content
    loc = users(:officer).officer_locations.newest_first.first
    assert_in_delta 40.1, loc.latitude.to_f, 0.0001
    assert_in_delta(-74.2, loc.longitude.to_f, 0.0001)
    assert_equal 15.0, loc.accuracy_meters
  end

  test "create rejects missing coordinates" do
    post officer_locations_path, params: { latitude: 40.1 }
    assert_response :unprocessable_content
  end

  test "create rejects out-of-range coordinates" do
    post officer_locations_path, params: { latitude: 999, longitude: -74.2 }
    assert_response :unprocessable_content
  end

  test "create requires an officer role" do
    sign_in_as users(:one)
    post officer_locations_path, params: { latitude: 40.1, longitude: -74.2 }
    assert_response :redirect
  end
end
