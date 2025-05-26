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
end
