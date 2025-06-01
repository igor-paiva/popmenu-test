class RestaurantsController < ApplicationController
  before_action :set_restaurant, only: %i[show]

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def index
    @restaurants = Restaurant.all
  end

  def show; end

  def import
    import_status = ImportStatus.new(status: :pending)

    import_status.file = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new(import_permitted_params.to_json),
      filename: "import_restaurants_#{Time.zone.now.strftime("%Y%m%d%H%M%S")}.json",
      content_type: "application/json"
    )

    import_status.save!

    ImportRestaurantsJob.perform_later(import_status.id)

    render json: { import_status_id: import_status.id, message: "Import received" }, status: :accepted
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
