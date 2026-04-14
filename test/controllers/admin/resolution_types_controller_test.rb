require "test_helper"

class Admin::ResolutionTypesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:admin) }

  test "index renders" do
    get admin_resolution_types_path
    assert_response :success
  end

  test "new renders the form" do
    get new_admin_resolution_type_path
    assert_response :success
    assert_select "form"
  end

  test "create adds a resolution type" do
    assert_difference -> { ResolutionType.count }, 1 do
      post admin_resolution_types_path, params: { resolution_type: { name: "Warning given", position: 5, active: true } }
    end
    assert_redirected_to admin_resolution_types_path
  end

  test "edit renders the form" do
    get edit_admin_resolution_type_path(resolution_types(:summons))
    assert_response :success
    assert_select "form"
  end

  test "update edits a type" do
    patch admin_resolution_type_path(resolution_types(:summons)), params: {
      resolution_type: { name: "Summons issued (updated)" }
    }
    assert_redirected_to admin_resolution_types_path
    assert_equal "Summons issued (updated)", resolution_types(:summons).reload.name
  end

  test "destroy removes when no resolutions" do
    type = ResolutionType.create!(name: "Temp", position: 99, active: true)
    assert_difference -> { ResolutionType.count }, -1 do
      delete admin_resolution_type_path(type)
    end
  end

  test "non-admin cannot access" do
    sign_in_as users(:one)
    get admin_resolution_types_path
    assert_response :redirect
  end
end
