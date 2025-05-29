require "test_helper"

class RestaurantsControllerTest < ActionDispatch::IntegrationTest
  test "should return all restaurants on index" do
    get restaurants_url, as: :json

    assert_response :success

    assert_equal 2, response.parsed_body.count
  end

  test "should return restaurant with menus on show" do
    restaurant = restaurants(:one)

    get restaurant_url(restaurant), as: :json

    assert_response :success

    parsed_response = response.parsed_body

    assert_equal restaurant.id, parsed_response["id"]
    assert_equal restaurant.name, parsed_response["name"]

    assert_equal 2, parsed_response["menus"].count
  end

  test "should import restaurants from JSON file" do
    assert_difference "MenuMenuItem.count", 8 do
      assert_difference "Restaurant.count", 2 do
        assert_difference "Menu.count", 4 do
          assert_difference "MenuItem.count", 6 do
            post import_restaurants_url, params: JSON.parse(file_fixture("restaurants.json").read), as: :json

            assert_response :success
          end
        end
      end
    end

    parsed_response = response.parsed_body

    assert_equal(
      { "success" => true, "errors" => [], "message" => "Restaurants imported successfully" },
      parsed_response["general"]
    )

    assert_equal 2, parsed_response.dig("restaurants", "success").count
    assert_equal 4, parsed_response.dig("menus", "success").count
    assert_equal 9, parsed_response.dig("menu_items", "success").count
    assert_nil parsed_response["menu_menu_items"]

    restaurant_one = Restaurant.find_by!(name: "Poppo's Cafe")
    restaurant_two = Restaurant.find_by!(name: "Casa del Poppo")

    restaurant_one_menus = restaurant_one.menus.sort_by(&:name)
    restaurant_two_menus = restaurant_two.menus.sort_by(&:name)

    assert_equal(%w[dinner lunch], restaurant_one_menus.pluck(:name).sort)
    assert_equal(%w[dinner lunch], restaurant_two_menus.pluck(:name).sort)

    restaurant_one_dinner_menu = restaurant_one_menus.first
    restaurant_one_lunch_menu = restaurant_one_menus.last

    burger_item = MenuItem.find_by!(name: "Burger")
    small_salad_item = MenuItem.find_by!(name: "Small Salad")
    large_salad_item = MenuItem.find_by!(name: "Large Salad")
    chicken_wings_item = MenuItem.find_by!(name: "Chicken Wings")
    mega_burger_item = MenuItem.find_by!(name: "Mega \"Burger\"")
    lobster_mac_and_cheese_item = MenuItem.find_by!(name: "Lobster Mac & Cheese")

    assert MenuMenuItem.exists?(
      menu: restaurant_one_lunch_menu, menu_item: burger_item, price: 9.0
    )
    assert MenuMenuItem.exists?(
      menu: restaurant_one_lunch_menu, menu_item: small_salad_item, price: 5.0
    )

    assert MenuMenuItem.exists?(
      menu: restaurant_one_dinner_menu, menu_item: burger_item, price: 15.0
    )
    assert MenuMenuItem.exists?(
      menu: restaurant_one_dinner_menu, menu_item: large_salad_item, price: 8.0
    )

    restaurant_two_dinner_menu = restaurant_two_menus.first
    restaurant_two_lunch_menu = restaurant_two_menus.last

    assert MenuMenuItem.exists?(
      menu: restaurant_two_lunch_menu, menu_item: chicken_wings_item, price: 9.0
    )
    assert MenuMenuItem.exists?(
      menu: restaurant_two_lunch_menu, menu_item: burger_item, price: 9.0
    )

    assert MenuMenuItem.exists?(
      menu: restaurant_two_dinner_menu, menu_item: mega_burger_item, price: 22.0
    )
    assert MenuMenuItem.exists?(
      menu: restaurant_two_dinner_menu, menu_item: lobster_mac_and_cheese_item, price: 31.0
    )
  end
end
