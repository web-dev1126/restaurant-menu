require "test_helper"

class MenuTest < ActiveSupport::TestCase
  def setup
    @restaurant = Restaurant.create!(name: "Test Restaurant")
    @menu = Menu.new(
      name: "Lunch Menu",
      description: "Delicious lunch options",
      active: true,
      restaurant: @restaurant
    )
  end

  test "should be valid" do
    assert @menu.valid?
  end

  test "name should be present" do
    @menu.name = nil
    assert_not @menu.valid?
  end

  test "name should be at least 2 characters" do
    @menu.name = "A"
    assert_not @menu.valid?
  end

  test "name should be at most 100 characters" do
    @menu.name = "A" * 101
    assert_not @menu.valid?
  end

  test "name should be unique within restaurant" do
    @menu.save
    duplicate_menu = Menu.new(name: "Lunch Menu", restaurant: @restaurant)
    assert_not duplicate_menu.valid?
  end

  test "name can be same in different restaurants" do
    @menu.save
    other_restaurant = Restaurant.create!(name: "Other Restaurant")
    duplicate_menu = Menu.new(name: "Lunch Menu", restaurant: other_restaurant)
    assert duplicate_menu.valid?
  end

  test "description should be at most 500 characters" do
    @menu.description = "A" * 501
    assert_not @menu.valid?
  end

  test "active should be boolean" do
    @menu.active = nil
    assert_not @menu.valid?
  end

  test "should have many menu items through join table" do
    @menu.save
    menu_item = MenuItem.create!(name: "Burger", price: 10.0, category: "Main Course")
    @menu.menu_items << menu_item
    assert_equal 1, @menu.menu_items.count
  end

  test "should destroy associated menu item menus" do
    @menu.save
    menu_item = MenuItem.create!(name: "Burger", price: 10.0, category: "Main Course")
    @menu.menu_items << menu_item
    assert_difference 'MenuItemMenu.count', -1 do
      @menu.destroy
    end
  end

  test "active scope should return only active menus" do
    @menu.save
    inactive_menu = Menu.create!(name: "Inactive Menu", active: false)
    assert_includes Menu.active, @menu
    assert_not_includes Menu.active, inactive_menu
  end

  test "ordered_by_name scope should return menus in alphabetical order" do
    Menu.create!(name: "Zebra Menu")
    Menu.create!(name: "Alpha Menu")
    menus = Menu.ordered_by_name
    assert_equal "Alpha Menu", menus.first.name
    assert_equal "Zebra Menu", menus.last.name
  end

  test "available_items_count should return count of available items" do
    @menu.save
    available_item = MenuItem.create!(name: "Available Item", price: 10.0, category: "Main", available: true)
    unavailable_item = MenuItem.create!(name: "Unavailable Item", price: 10.0, category: "Main", available: false)
    @menu.menu_items << available_item
    @menu.menu_items << unavailable_item
    assert_equal 1, @menu.available_items_count
  end

  test "total_items_count should return total count of items" do
    @menu.save
    item1 = MenuItem.create!(name: "Item 1", price: 10.0, category: "Main")
    item2 = MenuItem.create!(name: "Item 2", price: 10.0, category: "Main")
    @menu.menu_items << item1
    @menu.menu_items << item2
    assert_equal 2, @menu.total_items_count
  end
end 