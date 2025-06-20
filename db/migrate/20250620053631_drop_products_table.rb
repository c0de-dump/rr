class DropProductsTable < ActiveRecord::Migration[8.0]
  def change
    drop_table :subscribers, if_exists: true
    drop_table :products, if_exists: true
  end
end
