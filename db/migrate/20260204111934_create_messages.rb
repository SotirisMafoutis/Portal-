class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.text :body
      t.references :user, null: false, foreign_key: true
      t.integer :recipient_id
      t.string :conversation_id

      t.timestamps
    end
  end
end
