class AddRestaurantToMenus < ActiveRecord::Migration[8.0]
  def up
    # Create a default restaurant for existing menus
    default_restaurant = Restaurant.create!(
      name: "Default Restaurant",
      description: "Default restaurant for existing menus"
    )
    
    # Add restaurant_id column
    add_reference :menus, :restaurant, null: false, foreign_key: true, default: default_restaurant.id
    
    # Update existing menus to use the default restaurant
    Menu.update_all(restaurant_id: default_restaurant.id)
    
    # Remove the default value constraint
    change_column_default :menus, :restaurant_id, nil
  end

  def down
    remove_reference :menus, :restaurant, foreign_key: true
  end
end 