class CreateRestaurants < ActiveRecord::Migration[8.0]
  def change
    create_table :restaurants do |t|
      t.string :name, null: false
      t.text :description
      t.string :address
      t.string :phone
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :restaurants, :name, unique: true
  end
end 