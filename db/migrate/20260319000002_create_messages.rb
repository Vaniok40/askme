class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :user,         null: false, foreign_key: true
      t.text    :body,   null: false
      t.boolean :read,   null: false, default: false
      t.timestamps
    end
  end
end
