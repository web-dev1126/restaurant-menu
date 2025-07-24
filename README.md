# Restaurant Menu API

A comprehensive Rails API application for managing restaurant menus with support for multiple restaurants, menu items, and JSON data import functionality.

## Features

### Level 1: Basic Menu Management
- **Menu Model**: Create and manage restaurant menus with name, description, and active status
- **MenuItem Model**: Manage menu items with name, description, price, category, and availability
- **RESTful API**: Full CRUD operations for menus and menu items
- **Validation**: Comprehensive data validation and error handling
- **Testing**: Complete unit and integration test coverage

### Level 2: Multi-Restaurant Support
- **Restaurant Model**: Support for multiple restaurants with contact information
- **Many-to-Many Relationships**: Menu items can belong to multiple menus across restaurants
- **Global Uniqueness**: Menu item names are globally unique across all restaurants
- **Restaurant Scoping**: Menu names are unique within each restaurant
- **Enhanced API**: Nested routes for restaurant-specific operations

### Level 3: JSON Import System
- **HTTP Import Endpoint**: Upload JSON files or send JSON data via API
- **Command Line Tools**: Rake tasks for batch import operations
- **Smart Item Reuse**: Existing menu items are automatically reused
- **Flexible JSON Structure**: Supports both `menu_items` and `dishes` keys
- **Comprehensive Logging**: Detailed audit trails with timestamps
- **Error Recovery**: Graceful handling of partial import failures

## Technology Stack

- **Ruby**: 3.3.0
- **Rails**: 8.0.2 (API mode)
- **Database**: SQLite3
- **Testing**: Minitest with Rails testing framework
- **Architecture**: RESTful API with service objects

## Prerequisites

- Ruby 3.3.0
- Rails 8.0.2
- SQLite3

## Installation & Setup

### 1. Clone the Repository
```bash
git clone <repository-url>
cd restaurant-menu
```

### 2. Install Dependencies
```bash
bundle install
```

### 3. Setup Database
```bash
rails db:create
rails db:migrate
```

### 4. Run Tests
```bash
rails test
```

### 5. Start the Server
```bash
rails server
```

The API will be available at `http://localhost:3000`

## API Documentation

### Base URL
```
http://localhost:3000/api/v1
```

### Health Check
```bash
GET /
GET /health
```

### Level 1 & 2: Restaurant Management

#### List All Restaurants
```bash
GET /restaurants
```

#### Get Specific Restaurant
```bash
GET /restaurants/:id
```

#### Create Restaurant
```bash
POST /restaurants
Content-Type: application/json

{
  "restaurant": {
    "name": "My Restaurant",
    "description": "A great place to eat",
    "address": "123 Main St",
    "phone": "555-1234",
    "active": true
  }
}
```

#### Update Restaurant
```bash
PATCH /restaurants/:id
Content-Type: application/json

{
  "restaurant": {
    "name": "Updated Restaurant Name"
  }
}
```

#### Delete Restaurant
```bash
DELETE /restaurants/:id
```

### Menu Management

#### List Restaurant Menus
```bash
GET /restaurants/:restaurant_id/menus
```

#### Create Menu for Restaurant
```bash
POST /restaurants/:restaurant_id/menus
Content-Type: application/json

{
  "menu": {
    "name": "Lunch Menu",
    "description": "Delicious lunch options",
    "active": true
  }
}
```

#### Get Specific Menu
```bash
GET /menus/:id
```

#### Update Menu
```bash
PATCH /menus/:id
Content-Type: application/json

{
  "menu": {
    "name": "Updated Menu Name"
  }
}
```

#### Delete Menu
```bash
DELETE /menus/:id
```

### Menu Item Management

#### List Menu Items
```bash
GET /menus/:menu_id/menu_items
```

#### Create Menu Item
```bash
POST /menus/:menu_id/menu_items
Content-Type: application/json

{
  "menu_item": {
    "name": "Burger",
    "description": "Delicious beef burger",
    "price": 12.99,
    "category": "Main Course",
    "available": true
  }
}
```

#### Get Specific Menu Item
```bash
GET /menu_items/:id
```

#### Update Menu Item
```bash
PATCH /menu_items/:id
Content-Type: application/json

{
  "menu_item": {
    "price": 13.99
  }
}
```

#### Delete Menu Item
```bash
DELETE /menu_items/:id
```

### Level 3: JSON Import

#### Import from File Upload
```bash
POST /import
Content-Type: multipart/form-data

file: @restaurant_data.json
```

#### Import from JSON Data
```bash
POST /import
Content-Type: application/json

{
  "json_data": "{\"restaurants\":[...]}"
}
```

## JSON Import Format

The import system expects JSON data in the following format:

```json
{
  "restaurants": [
    {
      "name": "Restaurant Name",
      "description": "Optional description",
      "address": "Optional address",
      "phone": "Optional phone",
      "active": true,
      "menus": [
        {
          "name": "Menu Name",
          "description": "Optional description",
          "active": true,
          "menu_items": [
            {
              "name": "Item Name",
              "description": "Optional description",
              "price": 10.0,
              "category": "Optional category",
              "available": true
            }
          ]
        }
      ]
    }
  ]
}
```

### Import Features
- **Flexible Structure**: Supports both `menu_items` and `dishes` keys
- **Smart Item Reuse**: Existing menu items are reused automatically
- **Optional Fields**: Most fields are optional with sensible defaults
- **Global Uniqueness**: Menu item names are globally unique
- **Restaurant Scoping**: Menu names are unique within each restaurant

## Command Line Tools

### Import from File
```bash
# Import from default file (restaurant_data.json)
rails import:restaurants

# Import from specific file
rails import:restaurants[path/to/your/file.json]
```

### Import from JSON String
```bash
# Import from JSON string
rails "import:from_json['{\"restaurants\":[...]}']"
```

## Testing

### Run All Tests
```bash
rails test
```

### Run Specific Test Suites
```bash
# Model tests
rails test test/models/

# Controller tests
rails test test/controllers/

# Service tests
rails test test/services/

# Import functionality tests
rails test test/services/restaurant_import_service_test.rb
rails test test/controllers/api/v1/imports_controller_test.rb
```

### Test Coverage
- **120+ tests** covering all functionality
- **Model validations** and associations
- **API endpoints** and error handling
- **Import system** with edge cases
- **Database constraints** and relationships

## Database Schema

### Restaurants
- `id` (Primary Key)
- `name` (String, unique)
- `description` (Text)
- `address` (String)
- `phone` (String)
- `active` (Boolean, default: true)
- `created_at`, `updated_at`

### Menus
- `id` (Primary Key)
- `restaurant_id` (Foreign Key)
- `name` (String, unique within restaurant)
- `description` (Text)
- `active` (Boolean, default: true)
- `created_at`, `updated_at`

### Menu Items
- `id` (Primary Key)
- `name` (String, globally unique)
- `description` (Text)
- `price` (Decimal, precision: 8, scale: 2)
- `category` (String)
- `available` (Boolean, default: true)
- `created_at`, `updated_at`

### Menu Item Menus (Join Table)
- `id` (Primary Key)
- `menu_item_id` (Foreign Key)
- `menu_id` (Foreign Key)
- `created_at`, `updated_at`

## Configuration

### Environment Variables
- `RAILS_ENV`: Set to `development`, `test`, or `production`
- `DATABASE_URL`: Database connection string (optional)

### Database Configuration
The application uses SQLite3 by default. For production, update `config/database.yml` to use your preferred database.

## Deployment

### Production Setup
1. Set `RAILS_ENV=production`
2. Configure your production database
3. Run `rails db:migrate`
4. Start the Rails server with your preferred web server (Puma, Unicorn, etc.)

### Docker Deployment
```bash
# Build the Docker image
docker build -t restaurant-menu .

# Run the container
docker run -p 3000:3000 restaurant-menu
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For issues and questions:
1. Check the test suite for usage examples
2. Review the API documentation above
3. Check the Rails logs for detailed error messages
4. Ensure your JSON format matches the expected schema

## Development Levels Summary

### Level 1: Basic Menu Management
- Core models and database schema
- RESTful API endpoints
- Comprehensive testing
- Data validation

### Level 2: Multi-Restaurant Support
- Restaurant model with many-to-many relationships
- Enhanced API with nested routes
- Global uniqueness constraints
- Advanced testing scenarios

### Level 3: JSON Import System
- HTTP import endpoints
- Command-line import tools
- Smart data processing
- Comprehensive error handling
- Detailed logging and audit trails
