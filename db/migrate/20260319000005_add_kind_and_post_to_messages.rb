class AddKindAndPostToMessages < ActiveRecord::Migration[6.0]
  def change
    add_column :messages, :kind, :string
    add_column :messages, :post_id, :integer
  end
end
