class AddAdminAndDropAvatarUrlFromUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :admin, :boolean, default: false, null: false
    remove_column :users, :avatar_url, :string
  end
end
