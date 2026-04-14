require "test_helper"

class Admin::CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:admin) }

  test "index renders categories" do
    get admin_categories_path
    assert_response :success
  end

  test "creating a category" do
    assert_difference -> { Category.count }, 1 do
      post admin_categories_path, params: { category: { name: "Idling in loading zone", position: 100, active: "1" } }
    end
    assert_redirected_to admin_categories_path
  end

  test "updating a category" do
    category = categories(:crosswalk)
    patch admin_category_path(category), params: { category: { name: "Renamed", position: category.position, active: "1" } }
    assert_redirected_to admin_categories_path
    assert_equal "Renamed", category.reload.name
  end
end
