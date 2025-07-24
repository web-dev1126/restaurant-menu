class RestaurantImportService
  attr_reader :success_count, :error_count, :total_count, :logs

  def initialize
    @success_count = 0
    @error_count = 0
    @total_count = 0
    @logs = []
  end

  def import_from_json(json_data)
    log_info("Starting restaurant import from JSON data")
    
    begin
      data = JSON.parse(json_data)
      process_restaurants(data['restaurants'])
    rescue JSON::ParserError => e
      log_error("Invalid JSON format: #{e.message}")
      return false
    rescue StandardError => e
      log_error("Unexpected error during import: #{e.message}")
      return false
    end

    log_info("Import completed. Success: #{@success_count}, Errors: #{@error_count}, Total: #{@total_count}")
    @success_count > 0
  end

  def import_from_file(file_path)
    log_info("Starting restaurant import from file: #{file_path}")
    
    begin
      json_data = File.read(file_path)
      import_from_json(json_data)
    rescue Errno::ENOENT => e
      log_error("File not found: #{e.message}")
      false
    rescue StandardError => e
      log_error("Error reading file: #{e.message}")
      false
    end
  end

  private

  def process_restaurants(restaurants_data)
    return unless restaurants_data.is_a?(Array)

    restaurants_data.each_with_index do |restaurant_data, index|
      @total_count += 1
      begin
        process_restaurant(restaurant_data, index)
        @success_count += 1
      rescue StandardError => e
        @error_count += 1
        log_error("Error processing restaurant at index #{index}: #{e.message}")
      end
    end
  end

  def process_restaurant(restaurant_data, index)
    restaurant_name = restaurant_data['name']
    return unless restaurant_name

    restaurant = Restaurant.find_or_create_by(name: restaurant_name) do |r|
      r.description = restaurant_data['description']
      r.address = restaurant_data['address']
      r.phone = restaurant_data['phone']
      r.active = restaurant_data['active'] != false
    end

    if restaurant.persisted?
      log_info("Found existing restaurant: #{restaurant_name}")
    else
      log_info("Created new restaurant: #{restaurant_name}")
    end

    process_menus(restaurant, restaurant_data['menus'])
    log_success("Restaurant '#{restaurant_name}' processed successfully")
  end

  def process_menus(restaurant, menus_data)
    return unless menus_data.is_a?(Array)

    menus_data.each_with_index do |menu_data, index|
      begin
        process_menu(restaurant, menu_data, index)
      rescue StandardError => e
        log_error("Error processing menu at index #{index} for restaurant '#{restaurant.name}': #{e.message}")
        raise e
      end
    end
  end

  def process_menu(restaurant, menu_data, index)
    menu_name = menu_data['name']
    return unless menu_name

    menu = restaurant.menus.find_or_create_by(name: menu_name) do |m|
      m.description = menu_data['description']
      m.active = menu_data['active'] != false
    end

    if menu.persisted?
      log_info("Found existing menu: #{menu_name} for restaurant: #{restaurant.name}")
    else
      log_info("Created new menu: #{menu_name} for restaurant: #{restaurant.name}")
    end

    # Handle both 'menu_items' and 'dishes' keys for flexibility
    items_data = menu_data['menu_items'] || menu_data['dishes']
    process_menu_items(menu, items_data)
    log_success("Menu '#{menu_name}' for restaurant '#{restaurant.name}' processed successfully")
  end

  def process_menu_items(menu, items_data)
    return unless items_data.is_a?(Array)

    items_data.each do |item_data|
      item_name = item_data['name']
      next unless item_name

      # Try to find existing menu item by name (global uniqueness)
      menu_item = MenuItem.find_by(name: item_name)
      
      if menu_item
        # Associate existing menu item with this menu
        unless menu.menu_items.include?(menu_item)
          menu.menu_items << menu_item
          log_info("Associated existing menu item '#{item_name}' with menu '#{menu.name}'")
        else
          log_info("Menu item '#{item_name}' already associated with menu '#{menu.name}'")
        end
      else
        # Create new menu item
        menu_item = MenuItem.create!(
          name: item_name,
          description: item_data['description'],
          price: item_data['price'],
          category: item_data['category'] || 'Uncategorized',
          available: item_data['available'] != false
        )
        menu.menu_items << menu_item
        log_info("Created new menu item '#{item_name}' and associated with menu '#{menu.name}'")
      end
    end
  end

  def log_info(message)
    timestamp = Time.current.strftime("%Y-%m-%d %H:%M:%S")
    @logs << "[#{timestamp}] INFO: #{message}"
    Rails.logger.info(message)
  end

  def log_success(message)
    timestamp = Time.current.strftime("%Y-%m-%d %H:%M:%S")
    @logs << "[#{timestamp}] SUCCESS: #{message}"
    Rails.logger.info(message)
  end

  def log_error(message)
    timestamp = Time.current.strftime("%Y-%m-%d %H:%M:%S")
    @logs << "[#{timestamp}] ERROR: #{message}"
    Rails.logger.error(message)
  end
end 