class AddGroupKeyToMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :messages, :group_key, :string
  end
end
