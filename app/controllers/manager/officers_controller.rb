class Manager::OfficersController < Manager::BaseController
  before_action :set_officer, only: %i[edit update destroy]

  def index
    @officers = User.enforcement.order(:email, :phone)
  end

  def new
    @officer = User.new(role: :enforcement)
  end

  def create
    @officer = User.new(officer_params.merge(role: :enforcement))
    if @officer.save
      redirect_to manager_officers_path, notice: "Officer created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    attrs = officer_params
    attrs = attrs.except(:password, :password_confirmation) if attrs[:password].blank?
    if @officer.update(attrs)
      redirect_to manager_officers_path, notice: "Officer updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @officer.destroy
    redirect_to manager_officers_path, notice: "Officer removed."
  end

  private

  def set_officer
    @officer = User.enforcement.find(params[:id])
  end

  def officer_params
    params.require(:user).permit(:email, :phone, :password, :password_confirmation)
  end
end
