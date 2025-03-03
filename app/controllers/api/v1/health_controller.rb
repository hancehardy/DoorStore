module Api
  module V1
    class HealthController < ApplicationController
      def check
        render json: { status: "ok", timestamp: Time.current }, status: :ok
      end
    end
  end
end
