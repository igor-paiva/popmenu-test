class RestaurantsController < ApplicationController
  before_action :set_restaurant, only: %i[show]

  def index
    @restaurants = Restaurant.all
  end

  def show; end

  private

    def set_restaurant
      @restaurant = Restaurant.find_by(id: params[:id])
    end
end
