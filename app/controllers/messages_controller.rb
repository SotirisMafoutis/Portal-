# app/controllers/messages_controller.rb

class MessagesController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  def index
    my_sent_ids = Message.where(user_id: current_user.id).pluck(:id)
    my_received_ids = MessageRecipient.where(user_id: current_user.id).pluck(:message_id)
    all_msg_ids = (my_sent_ids + my_received_ids).uniq

    all_messages = Message.where(id: all_msg_ids).order(created_at: :desc)

    chats_hash = {}

    all_messages.each do |msg|
      participants = ([msg.user_id] + msg.message_recipients.pluck(:user_id)).sort
      key = participants.join(',')
      
      next if chats_hash.key?(key)

      others = User.where(id: participants - [current_user.id])
      is_group = participants.size > 2
      
      name = if is_group
               "Ομάδα: #{others.map { |u| u.username || u.email.split('@').first }.join(', ')}"
             else
               others.first&.username || others.first&.email&.split('@')&.first || "Άγνωστος"
             end

      chats_hash[key] = {
        id: (participants - [current_user.id]).join(','),
        name: name,
        last_message: msg.body.to_s.truncate(30),
        is_group: is_group,
        time: msg.created_at.strftime("%H:%M")
      }
    end

    render json: chats_hash.values
  end

  def create
    recipient_ids = Array(params[:recipient_ids]).map(&:to_i)
    @message = Message.new(user_id: current_user.id, body: params[:body])
    
    if @message.save
      recipient_ids.each do |rid|
        MessageRecipient.create(message_id: @message.id, user_id: rid)
        
        # Δημιουργία ειδοποίησης
        begin
          create_message_notification(rid, @message)
        rescue => e
          puts "============ NOTIFICATION ERROR ============"
          puts e.message
          puts e.backtrace.first(5)
          puts "==========================================="
        end
      end

      all_members = (recipient_ids + [current_user.id]).sort
      group_key = all_members.join(',')

      ActionCable.server.broadcast "chat_channel", {
        body: @message.body,
        sender_id: current_user.id,
        sender_name: current_user.username || current_user.email.split('@').first,
        group_key: group_key,
        all_participant_ids: all_members,
        time: Time.current.strftime("%H:%M")
      }
      render json: { status: 'success' }
    else
      render json: { error: @message.errors.full_messages }, status: 422
    end
  end

  def show
    user_ids = params[:id].split(',').map(&:to_i)
    target_user_id = user_ids.first
    
    is_contact = current_user.contacts.exists?(contact_id: target_user_id)

    # ΔΙΟΡΘΩΣΗ: Φιλτράρουμε τα μηνύματα για το ΣΥΓΚΕΚΡΙΜΕΝΟ chat
    # Όλοι οι συμμετέχοντες σε αυτή τη συνομιλία (ταξινομημένοι)
    all_participants = (user_ids + [current_user.id]).sort
    
    # Βρίσκουμε μόνο τα μηνύματα που έχουν ΑΚΡΙΒΩΣ αυτούς τους συμμετέχοντες
    all_messages = []
    
    Message.where(user_id: all_participants).includes(:message_recipients).each do |msg|
      # Παίρνουμε όλους τους συμμετέχοντες του μηνύματος (sender + recipients)
      msg_participants = ([msg.user_id] + msg.message_recipients.pluck(:user_id)).sort
      
      # Προσθέτουμε το μήνυμα μόνο αν ταιριάζουν ΑΚΡΙΒΩΣ οι συμμετέχοντες
      all_messages << msg if msg_participants == all_participants
    end
    
    @messages = all_messages.sort_by(&:created_at)

    render json: {
      is_contact: is_contact,
      messages: @messages.map { |m|
        { 
          body: m.body, 
          is_mine: m.user_id == current_user.id, 
          sender_name: m.sender&.username || m.sender&.email&.split('@')&.first, 
          time: m.created_at.strftime("%H:%M") 
        }
      }
    }
  end

  private

  def create_message_notification(recipient_id, message)
    puts "========================================="
    puts "Creating notification for user: #{recipient_id}"
    
    sender_name = current_user.username || current_user.email.split('@').first
    message_preview = message.body.truncate(50)
    
    # Παίρνουμε όλους τους παραλήπτες
    all_recipient_ids = message.message_recipients.pluck(:user_id)
    puts "All recipient IDs: #{all_recipient_ids.inspect}"
    
    recipients_count = all_recipient_ids.count
    is_group = recipients_count > 1
    
    puts "Is group? #{is_group} (recipients_count: #{recipients_count})"
    
    notification_message = if is_group
                            # Βρίσκουμε τα ονόματα των άλλων μελών (εκτός από sender και recipient)
                            other_member_ids = all_recipient_ids - [recipient_id]
                            puts "Other member IDs (excluding recipient #{recipient_id}): #{other_member_ids.inspect}"
                            
                            other_members = User.where(id: other_member_ids)
                                               .pluck(:username, :email)
                                               .map { |username, email| username || email.split('@').first }
                            
                            puts "Other member names: #{other_members.inspect}"
                            
                            if other_members.any?
                              group_info = other_members.join(', ')
                              "#{sender_name} στην ομάδα με #{group_info}: #{message_preview}"
                            else
                              "#{sender_name} στην ομάδα: #{message_preview}"
                            end
                          else
                            "#{sender_name} σου έστειλε: #{message_preview}"
                          end
    
    puts "Final notification message: #{notification_message}"
    puts "========================================="
    
    # Χρησιμοποιούμε τα υπάρχοντα πεδία της βάσης
    notification = Notification.create(
      user_id: recipient_id,
      actor_id: current_user.id,
      message: notification_message,
      read: false
    )
    
    if notification.persisted?
      puts "✅ Notification created! ID: #{notification.id}"
    else
      puts "❌ Failed to create notification!"
      puts "Errors: #{notification.errors.full_messages}"
    end
  end
end