require "test_helper"

class RestaurantTest < ActiveSupport::TestCase
  def setup
    @restaurant = Restaurant.new(
      name: "Test Restaurant",
      description: "A test restaurant",
      address: "123 Test St",
      phone: "555-1234",
      active: true
    )
  end

  test "should be valid" do
    assert @restaurant.valid?
  end

  test "name should be present" do
    @restaurant.name = nil
    assert_not @restaurant.valid?
  end

  test "name should be at least 2 characters" do
    @restaurant.name = "A"
    assert_not @restaurant.valid?
  end

  test "name should be at most 100 characters" do
    @restaurant.name = "A" * 101
    assert_not @restaurant.valid?
  end

  test "name should be unique" do
    @restaurant.save
    duplicate_restaurant = Restaurant.new(name: "Test Restaurant")
    assert_not duplicate_restaurant.valid?
  end

  test "description should be at most 500 characters" do
    @restaurant.description = "A" * 501
    assert_not @restaurant.valid?
  end

  test "address should be at most 200 characters" do
    @restaurant.address = "A" * 201
    assert_not @restaurant.valid?
  end

  test "phone should be at most 20 characters" do
    @restaurant.phone = "A" * 21
    assert_not @restaurant.valid?
  end

  test "active should be boolean" do
    @restaurant.active = nil
    assert_not @restaurant.valid?
  end

  test "should have many menus" do
    @restaurant.save
    @restaurant.menus.create!(name: "Lunch Menu")
    @restaurant.menus.create!(name: "Dinner Menu")
    assert_equal 2, @restaurant.menus.count
  end

  test "should destroy associated menus" do
    @restaurant.save
    @restaurant.menus.create!(name: "Lunch Menu")
    assert_difference 'Menu.count', -1 do
      @restaurant.destroy
    end
  end

  test "should have many menu items through menus" do
    @restaurant.save
    menu = @restaurant.menus.create!(name: "Lunch Menu")
    menu_item1 = MenuItem.create!(name: "Item 1", price: 10.0, category: "Main")
    menu_item2 = MenuItem.create!(name: "Item 2", price: 10.0, category: "Main")
    menu.menu_items << menu_item1
    menu.menu_items << menu_item2
    assert_equal 2, @restaurant.menu_items.count
  end

  test "active scope should return only active restaurants" do
    @restaurant.save
    inactive_restaurant = Restaurant.create!(name: "Inactive Restaurant", active: false)
    assert_includes Restaurant.active, @restaurant
    assert_not_includes Restaurant.active, inactive_restaurant
  end

  test "ordered_by_name scope should return restaurants in alphabetical order" do
    Restaurant.create!(name: "Zebra Restaurant")
    Restaurant.create!(name: "Alpha Restaurant")
    restaurants = Restaurant.ordered_by_name
    assert_equal "Alpha Restaurant", restaurants.first.name
    assert_equal "Zebra Restaurant", restaurants.last.name
  end

  test "active_menus_count should return count of active menus" do
    @restaurant.save
    @restaurant.menus.create!(name: "Active Menu", active: true)
    @restaurant.menus.create!(name: "Inactive Menu", active: false)
    assert_equal 1, @restaurant.active_menus_count
  end

  test "total_menus_count should return total count of menus" do
    @restaurant.save
    @restaurant.menus.create!(name: "Menu 1")
    @restaurant.menus.create!(name: "Menu 2")
    assert_equal 2, @restaurant.total_menus_count
  end

  test "total_menu_items_count should return total count of menu items" do
    @restaurant.save
    menu = @restaurant.menus.create!(name: "Lunch Menu")
    menu_item1 = MenuItem.create!(name: "Item 1", price: 10.0, category: "Main")
    menu_item2 = MenuItem.create!(name: "Item 2", price: 10.0, category: "Main")
    menu.menu_items << menu_item1
    menu.menu_items << menu_item2
    assert_equal 2, @restaurant.total_menu_items_count
  end

  test "available_menu_items_count should return count of available menu items" do
    @restaurant.save
    menu = @restaurant.menus.create!(name: "Lunch Menu")
    available_item = MenuItem.create!(name: "Available Item", price: 10.0, category: "Main", available: true)
    unavailable_item = MenuItem.create!(name: "Unavailable Item", price: 10.0, category: "Main", available: false)
    menu.menu_items << available_item
    menu.menu_items << unavailable_item
    assert_equal 1, @restaurant.available_menu_items_count
  end
end 