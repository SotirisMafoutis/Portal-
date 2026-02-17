class Room < ApplicationRecord
  has_many :room_users, dependent: :destroy
  has_many :users, through: :room_users
  has_many :messages, dependent: :destroy

  # Βρίσκει ή δημιουργεί ένα δωμάτιο για μια συγκεκριμένη ομάδα χρηστών
  def self.find_or_create_for_users(user_ids)
    sorted_ids = user_ids.map(&:to_i).sort
    
    # Ψάχνουμε δωμάτιο που έχει ακριβώς αυτούς τους χρήστες
    rooms = Room.joins(:room_users).group('rooms.id').having('count(room_users.user_id) = ?', sorted_ids.size)
    
    rooms.each do |room|
      if room.room_users.pluck(:user_id).sort == sorted_ids
        return room
      end
    end

    # Αν δεν υπάρχει, το φτιάχνουμε
    new_room = Room.create!(is_group: sorted_ids.size > 2)
    sorted_ids.each { |id| new_room.room_users.create!(user_id: id) }
    new_room
  end
end