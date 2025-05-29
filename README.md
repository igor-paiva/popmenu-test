# Restaurant Management System

## Getting Started

### Prerequisites

* Ruby (version as specified in `.ruby-version` or `Gemfile`). Development with 3.3.1
* Rails. Development with 8.0.2
* Database (PostgreSQL/MySQL/SQLite as configured). Developed with SQLite3

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   bundle install
   ```

3. Set up the database:
   ```bash
   bin/rails db:create
   bin/rails db:migrate
   bin/rails db:seed
   ```

### Running the Server

To start the Rails development server:

```bash
bin/rails server
```

The application will be available at `http://localhost:3000`

### Running Tests

To run the test suite:

```bash
# Run all tests
bin/rails test

# Run specific test folders
bin/rails test test/models/

# Run specific test file
bin/rails test test/controllers/restaurants_controller_test.rb
```

## Available Routes

The application provides the following API endpoints:

### Health Check
- `GET /up` - Health status endpoint (returns 200 if app is running)

### Restaurants
- `GET /restaurants` - List all restaurants

  **Example Response:**
  ```json
  [
    {
      "id": 1,
      "name": "Restaurant Name",
      "created_at": "2024-05-26T10:30:00.000Z",
      "updated_at": "2024-05-26T10:30:00.000Z"
    }
  ]
  ```

- `GET /restaurants/:id` - Show specific restaurant details with menus

  **Example Response:**
  ```json
  {
    "id": 1,
    "name": "Restaurant Name",
    "created_at": "2024-05-26T10:30:00.000Z",
    "updated_at": "2024-05-26T10:30:00.000Z",
    "menus": [
      {
        "id": 1,
        "name": "Lunch Menu",
        "description": "Our delicious lunch offerings",
        "created_at": "2024-05-26T10:30:00.000Z",
        "updated_at": "2024-05-26T10:30:00.000Z"
      }
    ]
  }
  ```

- `POST /restaurants/import` - Import restaurant data (uses ImportRestaurants service)

### Menus
- `GET /menus` - List all menus

  **Example Response:**
  ```json
  [
    {
      "id": 1,
      "name": "Lunch Menu",
      "description": "Our delicious lunch offerings",
      "created_at": "2024-05-26T10:30:00.000Z",
      "updated_at": "2024-05-26T10:30:00.000Z"
    }
  ]
  ```

- `GET /menus/:id` - Show specific menu details with menu items

  **Example Response:**
  ```json
  {
    "id": 1,
    "name": "Lunch Menu",
    "description": "Our delicious lunch offerings",
    "created_at": "2024-05-26T10:30:00.000Z",
    "updated_at": "2024-05-26T10:30:00.000Z",
    "menu_items": [
      {
        "id": 1,
        "name": "Burger",
        "description": "Delicious burger with fries",
        "price": 12.99,
        "picture_url": "https://example.com/burger.jpg",
        "created_at": "2024-05-26T10:30:00.000Z",
        "updated_at": "2024-05-26T10:30:00.000Z"
      }
    ]
  }
  ```

## ImportRestaurants Service

The application includes a service for importing restaurant data with nested menus and menu items.

### Quick Usage

```ruby
# Basic usage
result = ImportRestaurants.run(restaurants: restaurant_data)

# Check if import was successful
if result.dig(:general, :success)
  puts "Import successful: #{result.dig(:general, :message)}"
else
  puts "Import failed: #{result.dig(:general, :errors)}"
end
```

### Data Structure

The service expects restaurant data in the following format:

```ruby
{
  restaurants: [
    {
      name: "Restaurant Name",
      menus: [
        {
          name: "Menu Name",
          description: "Menu description",
          menu_items: [  # can also use :dishes
            {
              name: "Item Name",
              description: "Item description",
              price: 12.99,
              picture_url: "http://example.com/image.jpg"
            }
          ]
        }
      ]
    }
  ]
}
```

### Full Documentation

For complete documentation including:
- Detailed parameter structure
- Return value format
- Error handling
- Transaction behavior
- Upsert operations

Please refer to the comprehensive documentation in the `ImportRestaurants` class at `app/services/import_restaurants.rb`.
