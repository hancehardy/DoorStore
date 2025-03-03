module Admin
  class OrdersController < BaseController
    before_action :set_order, only: [ :show, :update, :destroy, :process_refund, :add_note ]

    def index
      @orders = Order.includes(:line_items, :user)
                    .order(created_at: :desc)

      @orders = @orders.where(status: params[:status]) if params[:status].present?
      @orders = @orders.where(payment_status: params[:payment_status]) if params[:payment_status].present?

      render json: OrderSerializer.new(@orders, include: [ :line_items, :user ]).serializable_hash
    end

    def show
      render json: OrderSerializer.new(@order, include: [ :line_items, :user ]).serializable_hash
    end

    def update
      return head :forbidden if @order.status == "completed" || @order.status == "cancelled"

      if @order.update(order_params)
        # Send email notification about order update
        OrderMailer.order_updated(@order).deliver_later
        render json: OrderSerializer.new(@order).serializable_hash
      else
        render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def process_refund
      result = RefundService.process(
        order: @order,
        amount: params[:amount],
        reason: params[:reason]
      )

      if result[:success]
        render json: { message: "Refund processed successfully" }
      else
        render json: { error: result[:error] }, status: :unprocessable_entity
      end
    end

    def add_note
      note = @order.notes.build(
        content: params[:content],
        user: current_user,
        internal: true
      )

      if note.save
        render json: { message: "Note added successfully" }
      else
        render json: { errors: note.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def set_order
      @order = Order.find(params[:id])
    end

    def order_params
      params.require(:order).permit(
        :status,
        :shipping_method,
        :shipping_rate,
        :shipping_address,
        :billing_address,
        :estimated_delivery_date,
        :notes,
        line_items_attributes: [ :id, :quantity, :_destroy ]
      )
    end
  end
end
