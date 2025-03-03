module Api
  module V1
    class CartsController < BaseController
      before_action :set_cart, only: [ :show, :update, :destroy ]

      def show
        render json: CartSerializer.new(@cart).serializable_hash
      end

      def create
        @cart = current_user.carts.build(cart_params)
        if @cart.save
          render json: CartSerializer.new(@cart).serializable_hash, status: :created
        else
          render json: { errors: @cart.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @cart.update(cart_params)
          render json: CartSerializer.new(@cart).serializable_hash
        else
          render json: { errors: @cart.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @cart.destroy
        head :no_content
      end

      private

      def set_cart
        @cart = current_user.carts.find(params[:id])
      end

      def cart_params
        params.require(:cart).permit(:notes, :expires_at)
      end
    end
  end
end
