class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :actor, class_name: 'User', foreign_key: 'actor_id', optional: true

  scope :unread, -> { where(read: false) }
  scope :recent, -> { order(created_at: :desc) }

  after_create_commit :broadcast_badge

  private

  def broadcast_badge
    count = user.notifications.unread.count
    broadcast_replace_to(
      [user, :notifications],
      target: "notification-badge",
      partial: "shared/notification_badge",
      locals: { count: count }
    )
  end
end