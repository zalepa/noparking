class Officer::LocationsController < Officer::BaseController
  # Officers POST their current position here periodically (client-side
  # throttled). We just record it; managers will consume these rows.
  def create
    Current.user.officer_locations.create!(
      latitude:  params.require(:latitude),
      longitude: params.require(:longitude),
      accuracy_meters: params[:accuracy_meters].presence,
      recorded_at: Time.current
    )
    head :no_content
  rescue ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_content
  end
end
