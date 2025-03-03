class RenameProductCategoryToType < ActiveRecord::Migration[8.0]
  def change
    rename_column :products, :category, :product_type
  end
end
