class MenusController < ApplicationController
  before_action :set_menu, only: %i[show]

  def index
    @menus = Menu.all
  end

  def show; end

  private

    def set_menu
      @menu = Menu.find_by(id: params[:id])
    end
end
