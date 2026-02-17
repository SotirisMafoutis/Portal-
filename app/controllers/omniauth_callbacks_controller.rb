class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # Αυτή η μέθοδος τρέχει όταν η Google μας στείλει πίσω τον χρήστη
  def google_oauth2
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      flash[:notice] = "Επιτυχής σύνδεση μέσω Google!"
      sign_in_and_redirect @user, event: :authentication
    else
      # Αν υπάρχει πρόβλημα, τον στέλνουμε στην εγγραφή
      session['devise.google_data'] = request.env['omniauth.auth'].except('extra')
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end

  def failure
    redirect_to root_path, alert: "Αποτυχία σύνδεσης. Προσπαθήστε ξανά."
  end
end