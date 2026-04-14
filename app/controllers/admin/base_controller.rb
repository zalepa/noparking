class Admin::BaseController < ApplicationController
  layout "admin"
  before_action :require_site_admin!

  private

  def require_site_admin!
    return if Current.user&.site_admin?
    redirect_to root_path, alert: "You don't have access to that area."
  end
end
