class Contact < ApplicationRecord
  belongs_to :user
  # Συνδέουμε το contact_id με τον πίνακα Users
  belongs_to :contact, class_name: 'User', foreign_key: 'contact_id'
end