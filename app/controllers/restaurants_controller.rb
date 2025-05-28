class RestaurantsController < ApplicationController
  before_action :set_restaurant, only: %i[show]

  def index
    @restaurants = Restaurant.all
  end

  def show; end

  def import
    Services::ImportRestaurants.new(import_permitted_params).run
  end

  private

    def set_restaurant
      @restaurant = Restaurant.find_by(id: params[:id])
    end

    def import_permitted_params
      params.permit(
        restaurants: [
          :name,
          menus: [
            :name,
            menu_items: %i[name price],
            dishes: %i[name price]
          ]
        ]
      )
    end
end
