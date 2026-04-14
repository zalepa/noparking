class IssuesController < ApplicationController
  before_action :set_categories, only: %i[new create]

  STATUS_FILTERS = %w[all open assigned resolved].freeze
  SORT_OPTIONS   = %w[newest oldest].freeze

  def index
    @status = STATUS_FILTERS.include?(params[:status]) ? params[:status] : "all"
    @sort   = SORT_OPTIONS.include?(params[:sort])     ? params[:sort]   : "newest"

    scope = Current.user.issues.with_attached_photo.includes(:category, resolution: :resolution_type)
    scope = case @status
    when "open"     then scope.open
    when "assigned" then scope.assigned
    when "resolved" then scope.resolved
    else scope
    end
    scope = scope.order(created_at: (@sort == "oldest" ? :asc : :desc))
    @issues = scope
  end

  def new
    @issue = Current.user.issues.build
  end

  def create
    @issue = Current.user.issues.build(issue_params)

    if @issue.save
      redirect_to issues_path, notice: "Your report has been submitted. Thank you for helping keep the neighborhood safe."
    else
      flash.now[:alert] = "We couldn't submit your report. Please check the form and try again."
      render :new, status: :unprocessable_content
    end
  end

  private

  def set_categories
    @categories = Category.active.ordered
  end

  def issue_params
    params.require(:issue).permit(:title, :notes, :category_id, :latitude, :longitude, :address, :photo_data)
  end
end
