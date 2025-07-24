require "test_helper"

class MenuItemMenuTest < ActiveSupport::TestCase
  def setup
    @restaurant = Restaurant.create!(name: "Test Restaurant")
    @menu = Menu.create!(name: "Test Menu", restaurant: @restaurant)
    @menu_item = MenuItem.create!(name: "Test Item", price: 10.0, category: "Main Course")
    @menu_item_menu = MenuItemMenu.new(menu_item: @menu_item, menu: @menu)
  end

  test "should be valid" do
    assert @menu_item_menu.valid?
  end

  test "should belong to menu item" do
    @menu_item_menu.menu_item = nil
    assert_not @menu_item_menu.valid?
  end

  test "should belong to menu" do
    @menu_item_menu.menu = nil
    assert_not @menu_item_menu.valid?
  end

  test "menu item should be unique within menu" do
    @menu_item_menu.save
    duplicate = MenuItemMenu.new(menu_item: @menu_item, menu: @menu)
    assert_not duplicate.valid?
  end

  test "same menu item can be in different menus" do
    @menu_item_menu.save
    other_menu = Menu.create!(name: "Other Menu", restaurant: @restaurant)
    duplicate = MenuItemMenu.new(menu_item: @menu_item, menu: other_menu)
    assert duplicate.valid?
  end
end 