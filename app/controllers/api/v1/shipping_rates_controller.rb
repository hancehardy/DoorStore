module Api
  module V1
    class ShippingRatesController < BaseController
      before_action :set_order

      def calculate
        rates = @order.calculate_shipping_rates(shipping_params[:postal_code])

        if rates[:error].present?
          render json: { error: rates[:error] }, status: :unprocessable_entity
        else
          render json: { rates: rates }
        end
      end

      private

      def set_order
        @order = current_user.orders.find(params[:order_id])
      end

      def shipping_params
        params.require(:shipping).permit(:postal_code)
      end
    end
  end
end
