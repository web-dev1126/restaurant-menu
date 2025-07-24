class Api::V1::ImportsController < ApplicationController
  require_relative '../../../../lib/restaurant_import_service'
  
  def create
    if params[:file].present?
      handle_file_upload
    elsif params[:json_data].present?
      handle_json_data
    else
      render json: { error: "No file or JSON data provided" }, status: :bad_request
    end
  end

  private

  def handle_file_upload
    uploaded_file = params[:file]
    
    unless uploaded_file.content_type == 'application/json'
      render json: { error: "File must be a JSON file" }, status: :unprocessable_entity
      return
    end

    begin
      # Save uploaded file to temporary location
      temp_file_path = Rails.root.join('tmp', "import_#{Time.current.to_i}_#{SecureRandom.hex(8)}.json")
      File.binwrite(temp_file_path, uploaded_file.read)

      # Import the data
      service = ::RestaurantImportService.new
      result = service.import_from_file(temp_file_path)

      # Clean up temporary file
      File.delete(temp_file_path) if File.exist?(temp_file_path)

      if result
        render json: {
          success: true,
          logs: service.logs,
          summary: {
            total_processed: service.total_count,
            successful: service.success_count,
            errors: service.error_count
          }
        }
      else
        render json: {
          success: false,
          logs: service.logs,
          summary: {
            total_processed: service.total_count,
            successful: service.success_count,
            errors: service.error_count
          }
        }, status: :unprocessable_entity
      end

    rescue StandardError => e
      render json: {
        error: "Error processing uploaded file",
        details: e.message,
        success: false,
        logs: ["[#{Time.current.strftime('%Y-%m-%d %H:%M:%S')}] ERROR: #{e.message}"]
      }, status: :internal_server_error
    end
  end

  def handle_json_data
    begin
      service = ::RestaurantImportService.new
      result = service.import_from_json(params[:json_data])
      
      if result
        render json: {
          success: true,
          logs: service.logs,
          summary: {
            total_processed: service.total_count,
            successful: service.success_count,
            errors: service.error_count
          }
        }
      else
        render json: {
          success: false,
          logs: service.logs,
          summary: {
            total_processed: service.total_count,
            successful: service.success_count,
            errors: service.error_count
          }
        }, status: :unprocessable_entity
      end

    rescue StandardError => e
      render json: {
        error: "Error processing JSON data",
        details: e.message,
        success: false,
        logs: ["[#{Time.current.strftime('%Y-%m-%d %H:%M:%S')}] ERROR: #{e.message}"]
      }, status: :internal_server_error
    end
  end
end 