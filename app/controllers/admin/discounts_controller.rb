module Admin
  class DiscountsController < BaseController
    before_action :set_discount, only: [ :show, :update, :destroy ]

    def index
      @discounts = Discount.all
      render json: DiscountSerializer.new(@discounts).serializable_hash
    end

    def show
      render json: DiscountSerializer.new(@discount).serializable_hash
    end

    def create
      @discount = Discount.new(discount_params)

      if @discount.save
        render json: DiscountSerializer.new(@discount).serializable_hash, status: :created
      else
        render json: { errors: @discount.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      if @discount.update(discount_params)
        render json: DiscountSerializer.new(@discount).serializable_hash
      else
        render json: { errors: @discount.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @discount.destroy
      head :no_content
    end

    private

    def set_discount
      @discount = Discount.find(params[:id])
    end

    def discount_params
      params.require(:discount).permit(
        :code,
        :description,
        :discount_type,
        :amount,
        :minimum_order_amount,
        :starts_at,
        :ends_at,
        :usage_limit,
        :active,
        product_ids: []
      )
    end
  end
end
