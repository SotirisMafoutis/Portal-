class ContactsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: [:create] # Για ευκολία στο fetch

  def create
    contact_to_add = User.find_by(id: params[:contact_id])

    if contact_to_add && contact_to_add != current_user && !current_user.friend_users.include?(contact_to_add)
      current_user.friend_users << contact_to_add
      
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, notice: "Η επαφή προστέθηκε!" }
        format.json { render json: { status: 'success' } }
      end
    else
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path }
        format.json { render json: { status: 'error' }, status: :unprocessable_entity }
      end
    end
  end
end