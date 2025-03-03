module Api
  module V1
    class DiscountsController < BaseController
      skip_before_action :authenticate_user!, only: [ :index, :show ]

      def index
        @discounts = Discount.active
        render json: DiscountSerializer.new(@discounts).serializable_hash
      end

      def show
        @discount = Discount.find(params[:id])
        render json: DiscountSerializer.new(@discount).serializable_hash
      end
    end
  end
end
