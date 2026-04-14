require "test_helper"

class Officer::ResolutionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:officer)
    @issue = Issue.create!(user: users(:one), category: categories(:crosswalk),
                           title: "Report", latitude: 40.0, longitude: -74.0,
                           assigned_to: users(:officer), assigned_at: Time.current)
  end

  test "cannot resolve an issue not assigned to current officer" do
    other = User.create!(email: "other-resolve@example.com", password: "aVerySecret123!", role: :enforcement)
    @issue.update!(assigned_to: other)
    post officer_issue_resolution_path(@issue), params: {
      resolution: { resolution_type_id: resolution_types(:summons).id }
    }
    assert_redirected_to officer_issue_path(@issue)
    assert_nil @issue.reload.resolution
  end

  test "new renders the resolution form" do
    get new_officer_issue_resolution_path(@issue)
    assert_response :success
    assert_select "form"
  end

  test "create closes the issue with public note and internal citation" do
    assert_difference -> { Resolution.count }, 1 do
      post officer_issue_resolution_path(@issue), params: {
        resolution: {
          resolution_type_id: resolution_types(:summons).id,
          note: "Car was ticketed.",
          citation_number: "A1234"
        }
      }
    end
    assert_redirected_to officer_issue_path(@issue)
    @issue.reload
    assert @issue.resolved?
    assert_equal "Car was ticketed.", @issue.resolution.note
    assert_equal "A1234", @issue.resolution.citation_number
    assert_equal users(:officer), @issue.resolution.user
  end

  test "create fails without resolution type" do
    assert_no_difference -> { Resolution.count } do
      post officer_issue_resolution_path(@issue), params: { resolution: { note: "x" } }
    end
    assert_response :unprocessable_content
  end

  test "cannot resolve an already-resolved issue" do
    @issue.create_resolution!(user: users(:officer), resolution_type: resolution_types(:summons))
    post officer_issue_resolution_path(@issue), params: {
      resolution: { resolution_type_id: resolution_types(:not_illegal).id }
    }
    assert_redirected_to officer_issue_path(@issue)
  end

  test "non-officers cannot access" do
    sign_in_as users(:one)
    get new_officer_issue_resolution_path(@issue)
    assert_response :redirect
  end
end
