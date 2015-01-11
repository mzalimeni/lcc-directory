class ChildrenController < RestrictedController

  before_action :signed_in_user
  before_action :allowed_new,     only: [:new]
  before_action :allowed_create,  only: [:create]
  before_action :allowed_edit,    only: [:edit, :update]

  def new
    @child = Child.new
    @child.family_id = @user.id
  end

  def create
    @child = Child.new(child_params)
    if @child.save
      flash[:success] = 'Child successfully added!'
      redirect_to @user
    else
      render 'new', family_id: params[:family_id]
    end
  end

  def edit
    # @user already defined by before filters in this controller
    store_edit_return(user_path(@user.id))
  end

  def update
    if @child.update_attributes(child_params)
      flash[:success] = 'Child updated'
      redirect_to User.find(@child.family_id)
    else
      render 'edit'
    end
  end

  # Promote a child to a full user
  def promote
    child = Child.find(params[:id])
    user = User.new(child.attributes)
    store_edit_return edit_child_path(child)
    store_promoting child.id
    redirect_to new_user_path(user: user.attributes, promoting: child.id)
  end

  def destroy
    child = Child.find(params[:id])
    user = User.find(child.family_id)
    child.destroy
    flash[:success] = 'Child deleted'
    redirect_to user
  end

  private

    CHILD_PARAMS = :first_name, :last_name, :preferred_name, :birthday, :family_id
    def child_params
      params.require(:child).permit(CHILD_PARAMS)
    end

    # Before actions
    def allowed_new
      _allowed params[:id]
    end

    def allowed_create
      _allowed params[:child][:family_id]
    end

    def allowed_edit
      @child = Child.find(params[:id])
      _allowed @child.family_id
    end

    def _allowed(user_id)
      @user = User.find(user_id)
      redirect_to(root_url) unless current_user?(@user) || current_user.admin?
    end

end
