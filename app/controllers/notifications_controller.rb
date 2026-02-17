class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.recent.limit(50)
    current_user.notifications.unread.update_all(read: true)
    
    Turbo::StreamsChannel.broadcast_replace_to(
      [current_user, :notifications],
      target: "notification-badge",
      partial: "shared/notification_badge",
      locals: { count: 0 }
    )
  end
  
  def mark_as_read
    notification = current_user.notifications.find(params[:id])
    notification.update(read: true)
    head :ok
  end
  
  def mark_all_as_read
    current_user.notifications.unread.update_all(read: true)
    
    Turbo::StreamsChannel.broadcast_replace_to(
      [current_user, :notifications],
      target: "notification-badge",
      partial: "shared/notification_badge",
      locals: { count: 0 }
    )
    
    redirect_to notifications_path, notice: "Όλες οι ειδοποιήσεις σημειώθηκαν ως αναγνωσμένες"
  end
end