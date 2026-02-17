class CreateNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :sender, foreign_key: { to_table: :users }
      t.references :message, foreign_key: true
      t.integer :notification_type, default: 0
      t.string :title
      t.text :body
      t.boolean :read, default: false
      
      t.timestamps
    end
    
    add_index :notifications, [:user_id, :read]
  end
end