class Officer::BaseController < ApplicationController
  layout "officer"
  before_action :require_officer!

  private

  def require_officer!
    return if Current.user&.enforcement?
    redirect_to root_path, alert: "You don't have access to that area."
  end

  # Reads `lat` / `lng` params (set by the geolocation Stimulus controller)
  # and returns them as floats, or nil if either is missing/invalid.
  def current_coordinates
    lat = Float(params[:lat], exception: false)
    lng = Float(params[:lng], exception: false)
    return nil if lat.nil? || lng.nil?
    [ lat, lng ]
  end
  helper_method :current_coordinates
end
