class ProfilesController < ApplicationController
  before_action :set_user

  def edit
  end

  def update
    unless @user.authenticate(params.dig(:user, :current_password).to_s)
      @user.errors.add(:current_password, "is incorrect")
      flash.now[:alert] = "Please enter your current password to save changes."
      render :edit, status: :unprocessable_content and return
    end

    attrs = profile_params
    password_changed = attrs[:password].present?

    # Ignore password fields entirely if the user left them blank.
    unless password_changed
      attrs.delete(:password)
      attrs.delete(:password_confirmation)
    end

    if @user.update(attrs)
      # Revoke other sessions when the password changes; keep the current one alive.
      @user.sessions.where.not(id: Current.session.id).destroy_all if password_changed

      notice = if password_changed
                 "Profile and password updated. Other devices have been signed out."
      else
                 "Profile updated."
      end
      redirect_to edit_profile_path, notice: notice
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_user
    @user = Current.user
  end

  def profile_params
    params.require(:user).permit(:email, :phone, :password, :password_confirmation).to_h
  end
end
