class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  before_action :redirect_if_authenticated, only: %i[new create]
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to new_session_path, alert: "Too many attempts. Please try again in a few minutes." }

  def new
  end

  def create
    user = User.authenticate_by_login(
      identifier: params[:login],
      password: params[:password]
    )

    if user
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path,
                  alert: "We couldn't find an account matching that email or phone and password.",
                  status: :see_other
    end
  end

  def destroy
    terminate_session
    redirect_to root_path, notice: "You've been signed out.", status: :see_other
  end

  private

  def redirect_if_authenticated
    redirect_to issues_path if authenticated?
  end
end
