class AddContactIdToContacts < ActiveRecord::Migration[8.1]
  def change
    add_column :contacts, :contact_id, :integer
  end
end
