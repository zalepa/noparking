class Officer::DashboardsController < Officer::BaseController
  def show
    scope = Issue.unresolved.with_attached_photo.includes(:category, :assigned_to)

    if (coords = current_coordinates)
      @coordinates = coords
      @issues = scope.to_a.sort_by { |i| i.distance_miles_from(*coords) }.first(20)
    else
      @issues = scope.newest_first.limit(20)
    end
  end
end
