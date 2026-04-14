class Admin::CategoriesController < Admin::BaseController
  before_action :set_category, only: %i[edit update destroy]

  def index
    @categories = Category.ordered
  end

  def new
    @category = Category.new(active: true, position: next_position)
  end

  def create
    @category = Category.new(category_params)
    @category.position ||= next_position
    if @category.save
      redirect_to admin_categories_path, notice: "Category created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to admin_categories_path, notice: "Category updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @category.destroy
      redirect_to admin_categories_path, notice: "Category removed."
    else
      redirect_to admin_categories_path, alert: @category.errors.full_messages.to_sentence
    end
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :position, :active)
  end

  def next_position
    (Category.maximum(:position) || 0) + 1
  end
end
