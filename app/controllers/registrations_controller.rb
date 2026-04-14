class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  before_action :redirect_if_authenticated
  rate_limit to: 10, within: 10.minutes, only: :create,
             with: -> { redirect_to new_registration_path, alert: "Too many attempts. Please try again in a few minutes." }

  def new
    @user = User.new
    @contact_method = params[:contact_method].presence_in(%w[email phone]) || "email"
  end

  def create
    @contact_method = registration_params[:contact_method].presence_in(%w[email phone]) || "email"
    @user = User.new(user_attributes_from_params)

    if @user.save
      start_new_session_for(@user)
      redirect_to issues_path, notice: t("registrations_controller.created", app_name: t("app.name"))
    else
      flash.now[:alert] = "We couldn't create your account. Please check the form and try again."
      render :new, status: :unprocessable_content
    end
  end

  private

  def registration_params
    params.require(:user).permit(:contact_method, :email, :phone, :password, :password_confirmation)
  end

  # Only persist the contact field matching the selected method, so switching
  # the toggle doesn't leak a stale value from the hidden input.
  def user_attributes_from_params
    attrs = registration_params.slice(:password, :password_confirmation).to_h
    if @contact_method == "phone"
      attrs[:phone] = registration_params[:phone]
    else
      attrs[:email] = registration_params[:email]
    end
    attrs
  end

  def redirect_if_authenticated
    redirect_to issues_path if authenticated?
  end
end
