class Admin::ManagersController < Admin::BaseController
  before_action :set_manager, only: %i[edit update destroy]

  def index
    @managers = User.manager.order(:email, :phone)
  end

  def new
    @manager = User.new(role: :manager)
  end

  def create
    @manager = User.new(manager_params.merge(role: :manager))
    if @manager.save
      redirect_to admin_managers_path, notice: "Manager created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    attrs = manager_params
    attrs = attrs.except(:password, :password_confirmation) if attrs[:password].blank?
    if @manager.update(attrs)
      redirect_to admin_managers_path, notice: "Manager updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @manager.destroy
    redirect_to admin_managers_path, notice: "Manager removed."
  end

  private

  def set_manager
    @manager = User.manager.find(params[:id])
  end

  def manager_params
    params.require(:user).permit(:email, :phone, :password, :password_confirmation)
  end
end
