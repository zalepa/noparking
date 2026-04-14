class Officer::IssuesController < Officer::BaseController
  def index
    scope = Issue.unresolved.with_attached_photo.includes(:category, :assigned_to)

    if (coords = current_coordinates)
      @coordinates = coords
      @issues = scope.to_a.sort_by { |i| i.distance_miles_from(*coords) }
    else
      @issues = scope.newest_first.to_a
    end
  end

  def show
    @issue = Issue.with_attached_photo.includes(:category).find(params[:id])
    @coordinates = current_coordinates
  end
end
