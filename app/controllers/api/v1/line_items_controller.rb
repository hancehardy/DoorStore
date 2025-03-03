module Api
  module V1
    class LineItemsController < BaseController
      before_action :set_order
      before_action :set_line_item, only: [ :show, :update, :destroy ]

      def index
        @line_items = @order.line_items.includes(:product)
        render json: LineItemSerializer.new(@line_items).serializable_hash
      end

      def show
        render json: LineItemSerializer.new(@line_item).serializable_hash
      end

      def create
        @line_item = @order.line_items.build(line_item_params)
        if @line_item.save
          @order.calculate_total_price
          @order.save
          render json: LineItemSerializer.new(@line_item).serializable_hash, status: :created
        else
          render json: { errors: @line_item.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @line_item.update(line_item_params)
          @line_item.order.calculate_total_price
          @line_item.order.save
          render json: LineItemSerializer.new(@line_item).serializable_hash
        else
          render json: { errors: @line_item.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        order = @line_item.order
        @line_item.destroy
        order.calculate_total_price
        order.save
        head :no_content
      end

      private

      def set_order
        @order = Order.find(params[:order_id])
      end

      def set_line_item
        @line_item = @order.line_items.find(params[:id])
      end

      def line_item_params
        params.require(:line_item).permit(
          :product_id,
          :quantity,
          :width,
          :height,
          :glass_option,
          :finish,
          :price_per_unit
        )
      end
    end
  end
end
