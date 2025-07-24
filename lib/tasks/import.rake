namespace :import do
  desc "Import restaurants from JSON file (default: restaurant_data.json)"
  task :restaurants, [:file_path] => :environment do |task, args|
    file_path = args[:file_path] || 'restaurant_data.json'
    
    puts "Starting import from file: #{file_path}"
    puts "=" * 50
    puts

    service = RestaurantImportService.new
    result = service.import_from_file(file_path)

    puts
    puts "Import Results:"
    puts "=" * 50
    puts "Success: #{result}"
    puts "Total Processed: #{service.total_count}"
    puts "Successful: #{service.success_count}"
    puts "Errors: #{service.error_count}"
    puts
    puts "Logs:"
    puts "=" * 50
    service.logs.each { |log| puts log }
    puts
    puts "=" * 50
    if result
      puts "Import completed successfully!"
    else
      puts "Import completed with errors."
    end
  end

  desc "Import restaurants from JSON string"
  task :from_json, [:json_string] => :environment do |task, args|
    json_string = args[:json_string]
    
    unless json_string
      puts "Error: JSON string is required"
      puts "Usage: rails 'import:from_json[\"{\\\"restaurants\\\":[...]}\"]'"
      exit 1
    end

    puts "Starting import from JSON data"
    puts "=" * 50
    puts

    service = RestaurantImportService.new
    result = service.import_from_json(json_string)

    puts
    puts "Import Results:"
    puts "=" * 50
    puts "Success: #{result}"
    puts "Total Processed: #{service.total_count}"
    puts "Successful: #{service.success_count}"
    puts "Errors: #{service.error_count}"
    puts
    puts "Logs:"
    puts "=" * 50
    service.logs.each { |log| puts log }
    puts
    puts "=" * 50
    if result
      puts "Import completed successfully!"
    else
      puts "Import completed with errors."
    end
  end
end 