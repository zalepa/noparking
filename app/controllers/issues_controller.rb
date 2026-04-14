class IssuesController < ApplicationController
  before_action :set_categories, only: %i[new create]

  def index
    @issues = Current.user.issues.with_attached_photo.includes(:category).newest_first
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
