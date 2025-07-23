require "test_helper"

class MenuItemTest < ActiveSupport::TestCase
  def setup
    @menu = Menu.create!(name: "Test Menu")
    @menu_item = MenuItem.new(
      name: "Test Item",
      description: "A test menu item",
      price: 10.0,
      category: "Main Course",
      available: true,
      menu: @menu
    )
  end

  test "should be valid" do
    assert @menu_item.valid?
  end

  test "name should be present" do
    @menu_item.name = nil
    assert_not @menu_item.valid?
  end

  test "name should be at least 2 characters" do
    @menu_item.name = "A"
    assert_not @menu_item.valid?
  end

  test "name should be at most 100 characters" do
    @menu_item.name = "A" * 101
    assert_not @menu_item.valid?
  end

  test "name should be unique within menu" do
    @menu_item.save
    duplicate_item = MenuItem.new(
      name: "Test Item",
      price: 10.0,
      category: "Main Course",
      menu: @menu
    )
    assert_not duplicate_item.valid?
  end

  test "name can be same in different menus" do
    @menu_item.save
    other_menu = Menu.create!(name: "Other Menu")
    duplicate_item = MenuItem.new(
      name: "Test Item",
      price: 10.0,
      category: "Main Course",
      menu: other_menu
    )
    assert duplicate_item.valid?
  end

  test "description should be at most 500 characters" do
    @menu_item.description = "A" * 501
    assert_not @menu_item.valid?
  end

  test "price should be present" do
    @menu_item.price = nil
    assert_not @menu_item.valid?
  end

  test "price should be greater than 0" do
    @menu_item.price = 0
    assert_not @menu_item.valid?
  end

  test "price should be numeric" do
    @menu_item.price = "invalid"
    assert_not @menu_item.valid?
  end

  test "category should be present" do
    @menu_item.category = nil
    assert_not @menu_item.valid?
  end

  test "category should be at least 2 characters" do
    @menu_item.category = "A"
    assert_not @menu_item.valid?
  end

  test "category should be at most 50 characters" do
    @menu_item.category = "A" * 51
    assert_not @menu_item.valid?
  end

  test "available should be boolean" do
    @menu_item.available = nil
    assert_not @menu_item.valid?
  end

  test "should belong to menu" do
    @menu_item.menu = nil
    assert_not @menu_item.valid?
  end

  test "available scope should return only available items" do
    @menu_item.save
    unavailable_item = MenuItem.create!(
      name: "Unavailable Item",
      price: 10.0,
      category: "Main Course",
      available: false,
      menu: @menu
    )
    assert_includes MenuItem.available, @menu_item
    assert_not_includes MenuItem.available, unavailable_item
  end

  test "by_category scope should filter by category" do
    @menu_item.save
    other_item = MenuItem.create!(
      name: "Other Item",
      price: 10.0,
      category: "Dessert",
      menu: @menu
    )
    main_course_items = MenuItem.by_category("Main Course")
    assert_includes main_course_items, @menu_item
    assert_not_includes main_course_items, other_item
  end

  test "ordered_by_name scope should return items in alphabetical order" do
    MenuItem.create!(name: "Zebra Item", price: 10.0, category: "Main", menu: @menu)
    MenuItem.create!(name: "Alpha Item", price: 10.0, category: "Main", menu: @menu)
    items = MenuItem.ordered_by_name
    assert_equal "Alpha Item", items.first.name
    assert_equal "Zebra Item", items.last.name
  end

  test "ordered_by_price scope should return items by price" do
    MenuItem.create!(name: "Expensive Item", price: 20.0, category: "Main", menu: @menu)
    MenuItem.create!(name: "Cheap Item", price: 5.0, category: "Main", menu: @menu)
    items = MenuItem.ordered_by_price
    assert_equal 5.0, items.first.price
    assert_equal 20.0, items.last.price
  end

  test "formatted_price should return formatted price string" do
    @menu_item.price = 10.5
    assert_equal "$10.50", @menu_item.formatted_price
  end

  test "available? should return availability status" do
    assert @menu_item.available?
    @menu_item.available = false
    assert_not @menu_item.available?
  end
end 