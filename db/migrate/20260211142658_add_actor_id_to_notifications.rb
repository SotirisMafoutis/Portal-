class AddActorIdToNotifications < ActiveRecord::Migration[8.1]
  def change
    add_column :notifications, :actor_id, :integer
  end
end
