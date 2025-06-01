class ImportStatusesController < ApplicationController
  before_action :set_import_status, only: %i[show]

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def show; end

  private

    def set_import_status
      @import_status = ImportStatus.find_by!(id: params[:id])
    end

    def record_not_found
      render json: { error: "Import status not found" }, status: :not_found
    end
end
