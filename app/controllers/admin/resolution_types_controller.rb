class Admin::ResolutionTypesController < Admin::BaseController
  before_action :set_resolution_type, only: %i[edit update destroy]

  def index
    @resolution_types = ResolutionType.ordered
  end

  def new
    @resolution_type = ResolutionType.new(active: true, position: next_position)
  end

  def create
    @resolution_type = ResolutionType.new(resolution_type_params)
    @resolution_type.position ||= next_position
    if @resolution_type.save
      redirect_to admin_resolution_types_path, notice: "Resolution type created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @resolution_type.update(resolution_type_params)
      redirect_to admin_resolution_types_path, notice: "Resolution type updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @resolution_type.destroy
      redirect_to admin_resolution_types_path, notice: "Resolution type removed."
    else
      redirect_to admin_resolution_types_path, alert: @resolution_type.errors.full_messages.to_sentence
    end
  end

  private

  def set_resolution_type
    @resolution_type = ResolutionType.find(params[:id])
  end

  def resolution_type_params
    params.require(:resolution_type).permit(:name, :position, :active)
  end

  def next_position
    (ResolutionType.maximum(:position) || 0) + 1
  end
end
