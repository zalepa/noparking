class Manager::BaseController < ApplicationController
  layout "manager"
  before_action :require_manager!

  private

  def require_manager!
    return if Current.user&.manager?
    redirect_to root_path, alert: "You don't have access to that area."
  end
end
