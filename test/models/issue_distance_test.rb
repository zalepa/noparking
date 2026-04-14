require "test_helper"

class IssueDistanceTest < ActiveSupport::TestCase
  test "distance_miles_from computes a known pair correctly" do
    issue = Issue.new(latitude: 40.7128, longitude: -74.0060) # NYC
    # Philadelphia: ~80 miles south-west of NYC
    distance = issue.distance_miles_from(39.9526, -75.1652)
    assert_in_delta 80, distance, 5
  end

  test "distance_miles_from zero at the same point" do
    issue = Issue.new(latitude: 40.0, longitude: -74.0)
    assert_in_delta 0, issue.distance_miles_from(40.0, -74.0), 0.001
  end

  test "missing coordinates return infinity" do
    issue = Issue.new(latitude: nil, longitude: nil)
    assert_equal Float::INFINITY, issue.distance_miles_from(40.0, -74.0)
  end
end
