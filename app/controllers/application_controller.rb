class ApplicationController < ActionController::API
  rescue_from StandardError, with: :internal_server_error

  private

    def internal_server_error(error)
      Rails.logger.error(error)

      render json: { error: "Internal server error" }, status: :internal_server_error
    end
end
