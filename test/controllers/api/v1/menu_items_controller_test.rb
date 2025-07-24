require "test_helper"

class Api::V1::MenuItemsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @restaurant = Restaurant.create!(name: "Test Restaurant")
    @menu = Menu.create!(name: "Test Menu", restaurant: @restaurant)
    @menu_item = MenuItem.create!(
      name: "Test Item",
      description: "Test Description",
      price: 10.0,
      category: "Main Course",
      available: true
    )
    @menu.menu_items << @menu_item
  end

  test "should get index" do
    get api_v1_menu_menu_items_url(@menu), as: :json
    assert_response :success
  end

  test "should create menu item" do
    assert_difference('MenuItem.count') do
      post api_v1_menu_menu_items_url(@menu), params: { 
        menu_item: { 
          name: "New Item", 
          description: "New Description", 
          price: 15.0, 
          category: "Dessert", 
          available: true 
        } 
      }, as: :json
    end

    assert_response :created
  end

  test "should create menu item with same name in different menu" do
    other_menu = Menu.create!(name: "Other Menu", restaurant: @restaurant)
    assert_no_difference('MenuItem.count') do
      post api_v1_menu_menu_items_url(other_menu), params: { 
        menu_item: { 
          name: "Test Item", 
          price: 15.0, 
          category: "Dessert", 
          available: true 
        } 
      }, as: :json
    end

    assert_response :created
  end

  test "should show menu item" do
    get api_v1_menu_item_url(@menu_item), as: :json
    assert_response :success
  end

  test "should update menu item" do
    patch api_v1_menu_item_url(@menu_item), params: { menu_item: { name: "Updated Item" } }, as: :json
    assert_response :success
  end

  test "should destroy menu item" do
    assert_difference('MenuItem.count', -1) do
      delete api_v1_menu_item_url(@menu_item), as: :json
    end

    assert_response :no_content
  end

  test "should not create menu item with invalid params" do
    assert_no_difference('MenuItem.count') do
      post api_v1_menu_menu_items_url(@menu), params: { menu_item: { name: "" } }, as: :json
    end

    assert_response :unprocessable_entity
  end

  test "should not update menu item with invalid params" do
    patch api_v1_menu_item_url(@menu_item), params: { menu_item: { price: -1 } }, as: :json
    assert_response :unprocessable_entity
  end

  test "should return 404 for non-existent menu item" do
    get api_v1_menu_item_url(999), as: :json
    assert_response :not_found
  end

  test "should return 404 for non-existent menu when creating item" do
    assert_no_difference('MenuItem.count') do
      post api_v1_menu_menu_items_url(999), params: { 
        menu_item: { name: "Test", price: 10.0, category: "Main" } 
      }, as: :json
    end

    assert_response :not_found
  end
end 