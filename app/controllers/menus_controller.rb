class MenusController < ApplicationController
  before_action :set_menu, only: %i[show]

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def index
    @menus = Menu.all
  end

  def show; end

  private

    def set_menu
      @menu = Menu.find_by!(id: params[:id])
    end

    def record_not_found
      render json: { error: "Menu not found" }, status: :not_found
    end
end
