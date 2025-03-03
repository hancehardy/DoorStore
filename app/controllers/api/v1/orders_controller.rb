module Api
  module V1
    class OrdersController < BaseController
      before_action :set_order, only: [ :show, :update, :submit ]

      def index
        @orders = Order.includes(:line_items, :products)
        @orders = @orders.active_drafts if params[:drafts].present?
        @orders = @orders.pending if params[:pending].present?
        @orders = @orders.completed if params[:completed].present?

        render json: OrderSerializer.new(@orders).serializable_hash
      end

      def current
        @order = current_user.orders.draft.last
        render json: OrderSerializer.new(@order, include: [ :line_items ]).serializable_hash
      end

      def show
        render json: OrderSerializer.new(@order, include: [ :line_items ]).serializable_hash
      end

      def create
        @order = Order.new(order_params)

        if @order.save
          render json: OrderSerializer.new(@order).serializable_hash, status: :created
        else
          render json: { errors: @order.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @order.update(order_params)
          render json: OrderSerializer.new(@order).serializable_hash
        else
          render json: { errors: @order.errors }, status: :unprocessable_entity
        end
      end

      def submit
        if @order.update(order_params.merge(status: "pending"))
          # Process payment
          process_payment

          # Update order status
          @order.mark_as_completed

          render json: OrderSerializer.new(@order).serializable_hash
        else
          render json: { errors: @order.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        @order.destroy
        head :no_content
      end

      private

      def set_order
        @order = current_user.orders.find(params[:id])
      end

      def order_params
        params.require(:order).permit(
          :shipping_address,
          :billing_address,
          :payment_token,
          :unit_preference
        )
      end

      def process_payment
        # Simulate payment processing
        # In a real application, this would integrate with a payment gateway
        sleep(1) # Simulate processing time
        true
      end
    end
  end
end
