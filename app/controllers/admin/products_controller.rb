module Admin
  class ProductsController < BaseController
    before_action :set_product, only: [ :show, :update, :destroy ]

    def index
      @products = Product.all
      render json: ProductSerializer.new(@products).serializable_hash
    end

    def show
      render json: ProductSerializer.new(@product).serializable_hash
    end

    def create
      @product = Product.new(product_params)

      if @product.save
        render json: ProductSerializer.new(@product).serializable_hash, status: :created
      else
        render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      if @product.update(product_params)
        render json: ProductSerializer.new(@product).serializable_hash
      else
        render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @product.destroy
      head :no_content
    end

    private

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(
        :name,
        :description,
        :base_price,
        :price_per_sqft,
        :product_type,
        :active,
        :min_width,
        :max_width,
        :min_height,
        :max_height,
        :meta_title,
        :meta_description,
        specifications: {}
      )
    end
  end
end
