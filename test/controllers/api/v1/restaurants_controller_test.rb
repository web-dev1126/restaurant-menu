require "test_helper"

class Api::V1::RestaurantsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @restaurant = Restaurant.create!(name: "Test Restaurant", description: "Test Description", active: true)
  end

  test "should get index" do
    get api_v1_restaurants_url, as: :json
    assert_response :success
  end

  test "should create restaurant" do
    assert_difference('Restaurant.count') do
      post api_v1_restaurants_url, params: { restaurant: { name: "New Restaurant", description: "New Description", active: true } }, as: :json
    end

    assert_response :created
  end

  test "should show restaurant" do
    get api_v1_restaurant_url(@restaurant), as: :json
    assert_response :success
  end

  test "should update restaurant" do
    patch api_v1_restaurant_url(@restaurant), params: { restaurant: { name: "Updated Restaurant" } }, as: :json
    assert_response :success
  end

  test "should destroy restaurant" do
    assert_difference('Restaurant.count', -1) do
      delete api_v1_restaurant_url(@restaurant), as: :json
    end

    assert_response :no_content
  end

  test "should not create restaurant with invalid params" do
    assert_no_difference('Restaurant.count') do
      post api_v1_restaurants_url, params: { restaurant: { name: "" } }, as: :json
    end

    assert_response :unprocessable_entity
  end

  test "should not update restaurant with invalid params" do
    patch api_v1_restaurant_url(@restaurant), params: { restaurant: { name: "" } }, as: :json
    assert_response :unprocessable_entity
  end

  test "should return 404 for non-existent restaurant" do
    get api_v1_restaurant_url(999), as: :json
    assert_response :not_found
  end
end 