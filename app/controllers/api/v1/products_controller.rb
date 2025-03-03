module Api
  module V1
    class ProductsController < BaseController
      skip_before_action :authenticate_user!, only: [ :index, :show ]

      def index
        @products = Product.active
        render json: ProductSerializer.new(@products).serializable_hash
      end

      def show
        @product = Product.find(params[:id])
        render json: ProductSerializer.new(@product).serializable_hash
      end
    end
  end
end
