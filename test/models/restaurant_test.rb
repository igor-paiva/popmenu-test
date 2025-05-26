require "test_helper"

class RestaurantTest < ActiveSupport::TestCase
  test "should create menu with multiple menu items" do
    restaurant = Restaurant.create!(
      name: "Test Restaurant",
      menus_attributes: [
        {
          name: "Test Menu",
          description: "Test Description",
          menu_items_attributes: [
            {
              name: "Test Bread",
              description: "Delicious test bread",
              price: 3.99
            }

          ]
        }
      ]
    )

    assert_equal 1, restaurant.menus.count

    restaurant.menus.build(name: "Test Menu 2", description: "Delicious test menu 2")

    restaurant.save!

    assert_equal 2, restaurant.menus.count
  end

  test "should NOT destroy menus when restaurant is destroyed" do
    restaurant = restaurants(:one)

    assert_no_difference "Menu.count" do
      restaurant.destroy!
    end

    assert_nil Restaurant.find_by(id: restaurant.id)
  end
end
