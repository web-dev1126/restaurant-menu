require "test_helper"

class Api::V1::MenusControllerTest < ActionDispatch::IntegrationTest
  def setup
    @menu = Menu.create!(name: "Test Menu", description: "Test Description", active: true)
  end

  test "should get index" do
    get api_v1_menus_url, as: :json
    assert_response :success
  end

  test "should create menu" do
    assert_difference('Menu.count') do
      post api_v1_menus_url, params: { menu: { name: "New Menu", description: "New Description", active: true } }, as: :json
    end

    assert_response :created
  end

  test "should show menu" do
    get api_v1_menu_url(@menu), as: :json
    assert_response :success
  end

  test "should update menu" do
    patch api_v1_menu_url(@menu), params: { menu: { name: "Updated Menu" } }, as: :json
    assert_response :success
  end

  test "should destroy menu" do
    assert_difference('Menu.count', -1) do
      delete api_v1_menu_url(@menu), as: :json
    end

    assert_response :no_content
  end

  test "should not create menu with invalid params" do
    assert_no_difference('Menu.count') do
      post api_v1_menus_url, params: { menu: { name: "" } }, as: :json
    end

    assert_response :unprocessable_entity
  end

  test "should not update menu with invalid params" do
    patch api_v1_menu_url(@menu), params: { menu: { name: "" } }, as: :json
    assert_response :unprocessable_entity
  end

  test "should return 404 for non-existent menu" do
    get api_v1_menu_url(999), as: :json
    assert_response :not_found
  end
end 