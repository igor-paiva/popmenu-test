class RestaurantsController < ApplicationController
  before_action :set_restaurant, only: %i[show]

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def index
    @restaurants = Restaurant.all
  end

  def show; end

  def import
    @result = ImportRestaurants.run(import_permitted_params)

    @result.delete(:menu_menu_items)

    return render json: @result, status: :unprocessable_entity unless @result[:general][:success]

    render json: @result, status: :ok
  end

  private

    def set_restaurant
      @restaurant = Restaurant.find_by!(id: params[:id])
    end

    def import_permitted_params
      params.permit(
        restaurants: [
          :name,
          menus: [
            :name,
            :description,
            menu_items: %i[name price description picture_url],
            dishes: %i[name price]
          ]
        ]
      )
    end

    def record_not_found
      render json: { error: "Restaurant not found" }, status: :not_found
    end
end
