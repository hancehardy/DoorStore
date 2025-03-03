module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!

    private

    def require_admin!
      unless current_user&.admin?
        render json: { error: "You are not authorized to access this area." }, status: :forbidden
      end
    end
  end
end
