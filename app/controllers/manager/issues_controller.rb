class Manager::IssuesController < Manager::BaseController
  def index
    @issues = Issue.with_attached_photo.includes(:category, :user).newest_first
    if (category_id = params[:category_id]).present?
      @issues = @issues.where(category_id: category_id)
    end
    @categories = Category.ordered
  end

  def show
    @issue = Issue.with_attached_photo.includes(:category, :user).find(params[:id])
  end
end
