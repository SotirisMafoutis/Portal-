class Message < ApplicationRecord
  belongs_to :sender, class_name: 'User', foreign_key: 'user_id'
  has_many :message_recipients, dependent: :destroy
  has_many :recipients, through: :message_recipients, source: :user
 has_many :notifications, dependent: :destroy
  
  validates :body, presence: true
end
