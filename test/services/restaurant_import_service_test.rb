require "test_helper"
require_relative '../../lib/restaurant_import_service'

class RestaurantImportServiceTest < ActiveSupport::TestCase
  def setup
    @service = RestaurantImportService.new
    @valid_json = {
      restaurants: [
        {
          name: "Test Restaurant",
          menus: [
            {
              name: "Lunch Menu",
              menu_items: [
                { name: "Burger", price: 10.0, category: "Main" },
                { name: "Salad", price: 8.0, category: "Appetizer" }
              ]
            }
          ]
        }
      ]
    }.to_json
  end

  test "should import valid JSON data successfully" do
    assert_difference 'Restaurant.count', 1 do
      assert_difference 'Menu.count', 1 do
        assert_difference 'MenuItem.count', 2 do
          result = @service.import_from_json(@valid_json)
          assert result
        end
      end
    end
  end

  test "should handle invalid JSON format" do
    invalid_json = "invalid json"
    result = @service.import_from_json(invalid_json)
    assert_not result
    assert_includes @service.logs.last, "Invalid JSON format"
  end

  test "should reuse existing menu items by name" do
    # Create existing menu item
    existing_item = MenuItem.create!(name: "Burger", price: 10.0, category: "Main")
    
    assert_no_difference 'MenuItem.count' do
      result = @service.import_from_json(@valid_json)
      assert result
    end
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
      result = @service.import_from_json(json_with_dishes)
      assert result
    end
  end

  test "should handle missing optional fields" do
    minimal_json = {
      restaurants: [
        {
          name: "Test Restaurant",
          menus: [
            {
              name: "Lunch Menu",
              menu_items: [
                { name: "Burger", price: 10.0 }
              ]
            }
          ]
        }
      ]
    }.to_json

    assert_difference 'MenuItem.count', 1 do
      result = @service.import_from_json(minimal_json)
      assert result
    end

    menu_item = MenuItem.find_by(name: "Burger")
    assert_equal "Uncategorized", menu_item.category
    assert menu_item.available
  end

  test "should handle empty restaurants array" do
    empty_json = { restaurants: [] }.to_json
    result = @service.import_from_json(empty_json)
    assert result
    assert_equal 0, @service.total_count
  end

  test "should handle missing restaurants key" do
    invalid_json = { other_key: [] }.to_json
    result = @service.import_from_json(invalid_json)
    assert result
    assert_equal 0, @service.total_count
  end

  test "should handle restaurant without menus" do
    json_no_menus = {
      restaurants: [
        { name: "Test Restaurant" }
      ]
    }.to_json

    assert_difference 'Restaurant.count', 1 do
      result = @service.import_from_json(json_no_menus)
      assert result
    end
  end

  test "should handle menu without items" do
    json_no_items = {
      restaurants: [
        {
          name: "Test Restaurant",
          menus: [
            { name: "Lunch Menu" }
          ]
        }
      ]
    }.to_json

    assert_difference 'Menu.count', 1 do
      result = @service.import_from_json(json_no_items)
      assert result
    end
  end

  test "should handle duplicate restaurant names" do
    # Create existing restaurant
    Restaurant.create!(name: "Test Restaurant")
    
    assert_no_difference 'Restaurant.count' do
      result = @service.import_from_json(@valid_json)
      assert result
    end
  end

  test "should handle duplicate menu names within restaurant" do
    restaurant = Restaurant.create!(name: "Test Restaurant")
    Menu.create!(name: "Lunch Menu", restaurant: restaurant)
    
    assert_no_difference 'Menu.count' do
      result = @service.import_from_json(@valid_json)
      assert result
    end
  end

  test "should provide detailed logging" do
    result = @service.import_from_json(@valid_json)
    assert result
    
    logs = @service.logs
    assert logs.any? { |log| log.include?("Created new restaurant") }
    assert logs.any? { |log| log.include?("Created new menu") }
    assert logs.any? { |log| log.include?("Created new menu item") }
    assert logs.any? { |log| log.include?("Import completed") }
  end

  test "should handle file import" do
    file_path = Rails.root.join('tmp', 'test_import.json')
    File.write(file_path, @valid_json)
    
    begin
      assert_difference 'Restaurant.count', 1 do
        result = @service.import_from_file(file_path.to_s)
        assert result
      end
    ensure
      File.delete(file_path) if File.exist?(file_path)
    end
  end

  test "should handle missing file" do
    result = @service.import_from_file('nonexistent_file.json')
    assert_not result
    assert_includes @service.logs.last, "File not found"
  end

  test "should handle validation errors gracefully" do
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

    result = @service.import_from_json(invalid_json)
    assert_not result
    assert @service.error_count > 0
  end

  test "should handle large data sets" do
    large_json = {
      restaurants: (1..10).map do |i|
        {
          name: "Large Test Restaurant #{i}",
          menus: (1..5).map do |j|
            {
              name: "Menu #{j}",
              menu_items: (1..10).map do |k|
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

    assert_difference 'Restaurant.count', 10 do
      result = @service.import_from_json(large_json)
      assert result
    end
  end
end 