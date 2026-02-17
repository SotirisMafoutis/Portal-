class AddSenderIdToMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :messages, :sender_id, :integer
  end
end
