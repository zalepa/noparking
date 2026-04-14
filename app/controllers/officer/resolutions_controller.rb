class Officer::ResolutionsController < Officer::BaseController
  before_action :set_issue

  def new
    return if redirect_if_not_assignable
    @resolution = @issue.build_resolution
    @resolution_types = ResolutionType.active.ordered
  end

  def create
    return if redirect_if_not_assignable

    @resolution = @issue.build_resolution(resolution_params)
    @resolution.user = Current.user

    if @resolution.save
      redirect_to officer_issue_path(@issue), notice: "Issue resolved."
    else
      @resolution_types = ResolutionType.active.ordered
      render :new, status: :unprocessable_content
    end
  end

  private

  def set_issue
    @issue = Issue.find(params[:issue_id])
  end

  def resolution_params
    params.require(:resolution).permit(:resolution_type_id, :note, :citation_number)
  end

  # An officer must have taken the issue on before resolving it.
  def redirect_if_not_assignable
    if @issue.resolution.present?
      redirect_to officer_issue_path(@issue), alert: "This issue is already resolved."
      return true
    end
    if @issue.assigned_to_id != Current.user.id
      redirect_to officer_issue_path(@issue), alert: "Take this issue on before resolving it."
      return true
    end
    false
  end
end
