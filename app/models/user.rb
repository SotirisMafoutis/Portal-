class User < ApplicationRecord
  # Προσθέτουμε ξανά το :omniauthable και τις υπόλοιπες ρυθμίσεις
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :posts         
  
  # Σχέσεις Chat (Σταθερή έκδοση)
  has_many :sent_messages, class_name: 'Message', foreign_key: 'user_id'
  has_many :message_recipients, dependent: :destroy
  has_many :received_messages, through: :message_recipients, source: :message


 
  
  
  has_many :notifications, dependent: :destroy
  
  
  
  
  
  # Σχέσεις Επαφών



  has_many :contacts, dependent: :destroy
  has_many :friend_users, through: :contacts, source: :contact

  before_create :set_default_username

  private

  def set_default_username
    self.username = self.email.split('@').first if self.username.blank?
  end
  # Μέθοδος για το Google Auth
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.username = auth.info.name 
    end
  end
 has_many :notifications, dependent: :destroy
has_many :sent_notifications, class_name: 'Notification', foreign_key: 'actor_id'

def unread_notifications_count
  notifications.unread.count
end
end