require "test_helper"

class Api::V1::ImportsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @valid_json = {
      restaurants: [
        {
          name: "Test Restaurant",
          menus: [
            {
              name: "Lunch Menu",
              menu_items: [
                { name: "Burger", price: 10.0, category: "Main" }
              ]
            }
          ]
        }
      ]
    }.to_json
  end

  test "should import from JSON data" do
    assert_difference 'Restaurant.count', 1 do
      post api_v1_import_url, params: { json_data: @valid_json }, as: :json
    end

    assert_response :success
    response_data = JSON.parse(response.body)
    assert response_data['success']
    assert response_data['logs'].any?
    assert_equal 1, response_data['summary']['total_processed']
  end

  test "should import from file upload" do
    file = fixture_file_upload('files/restaurant_data.json', 'application/json')
    
    assert_difference 'Restaurant.count', 2 do
      post api_v1_import_url, params: { file: file }
    end

    assert_response :success
    response_data = JSON.parse(response.body)
    assert response_data['success']
  end

  test "should handle invalid JSON format" do
    post api_v1_import_url, params: { json_data: "invalid json" }, as: :json
    
    assert_response :unprocessable_entity
    response_data = JSON.parse(response.body)
    assert_not response_data['success']
    assert response_data['logs'].any? { |log| log.include?("Invalid JSON format") }
  end

  test "should handle non-JSON file upload" do
    file = fixture_file_upload('files/test.txt', 'text/plain')
    post api_v1_import_url, params: { file: file }
    
    assert_response :unprocessable_entity
    response_data = JSON.parse(response.body)
    assert_equal "File must be a JSON file", response_data['error']
  end

  test "should handle missing file and JSON data" do
    post api_v1_import_url, as: :json
    
    assert_response :bad_request
    response_data = JSON.parse(response.body)
    assert_equal "No file or JSON data provided", response_data['error']
  end

  test "should handle validation errors in JSON data" do
    invalid_json = {
      restaurants: [
        {
          name: "", # Invalid: empty name
          menus: [
            {
              name: "Lunch Menu",
              menu_items: [
                { name: "Burger", price: -1 } # Invalid: negative price
              ]
            }
          ]
        }
      ]
    }.to_json

    post api_v1_import_url, params: { json_data: invalid_json }, as: :json
    
    assert_response :unprocessable_entity
    response_data = JSON.parse(response.body)
    assert_not response_data['success']
    assert response_data['summary']['errors'] > 0
  end

  test "should handle large JSON data" do
    large_json = {
      restaurants: (1..5).map do |i|
        {
          name: "Large Test Restaurant #{i}",
          menus: (1..3).map do |j|
            {
              name: "Menu #{j}",
              menu_items: (1..5).map do |k|
                {
                  name: "Item #{i}-#{j}-#{k}",
                  price: (i + j + k).to_f,
                  category: "Category #{k % 3}"
                }
              end
            }
          end
        }
      end
    }.to_json

    assert_difference 'Restaurant.count', 5 do
      post api_v1_import_url, params: { json_data: large_json }, as: :json
    end

    assert_response :success
    response_data = JSON.parse(response.body)
    assert response_data['success']
    assert_equal 5, response_data['summary']['total_processed']
  end

  test "should handle mixed success and error scenarios" do
    mixed_json = {
      restaurants: [
        {
          name: "Valid Restaurant",
          menus: [
            {
              name: "Valid Menu",
              menu_items: [
                { name: "Valid Item", price: 10.0, category: "Main" }
              ]
            }
          ]
        },
        {
          name: "", # Invalid: empty name
          menus: []
        }
      ]
    }.to_json

    assert_difference 'Restaurant.count', 1 do
      post api_v1_import_url, params: { json_data: mixed_json }, as: :json
    end

    assert_response :unprocessable_entity
    response_data = JSON.parse(response.body)
    assert_not response_data['success']
    assert_equal 2, response_data['summary']['total_processed']
    assert_equal 1, response_data['summary']['successful']
    assert_equal 1, response_data['summary']['errors']
  end

  test "should reuse existing menu items" do
    # Create existing menu item
    MenuItem.create!(name: "Burger", price: 10.0, category: "Main")
    
    assert_no_difference 'MenuItem.count' do
      post api_v1_import_url, params: { json_data: @valid_json }, as: :json
    end

    assert_response :success
  end

  test "should handle both menu_items and dishes keys" do
    json_with_dishes = {
      restaurants: [
        {
          name: "Test Restaurant",
          menus: [
            {
              name: "Lunch Menu",
              dishes: [
                { name: "Pizza", price: 12.0, category: "Main" }
              ]
            }
          ]
        }
      ]
    }.to_json

    assert_difference 'MenuItem.count', 1 do
      post api_v1_import_url, params: { json_data: json_with_dishes }, as: :json
    end

    assert_response :success
  end
end 