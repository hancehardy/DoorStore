module Admin
  class UsersController < BaseController
    before_action :set_user, only: [ :show, :update, :toggle_admin ]

    def index
      @users = User.all.order(created_at: :desc)
      render json: UserSerializer.new(@users).serializable_hash
    end

    def show
      render json: UserSerializer.new(@user).serializable_hash
    end

    def update
      if @user.update(user_params)
        render json: UserSerializer.new(@user).serializable_hash
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def toggle_admin
      was_admin = @user.admin?

      # Prevent removing admin status from the last admin user
      if was_admin && User.where(admin: true).count == 1
        render json: { error: "Cannot remove admin status from the last admin user" }, status: :unprocessable_entity
        return
      end

      @user.update!(admin: !was_admin)

      render json: {
        message: "User #{was_admin ? 'removed from' : 'added to'} administrators",
        user: UserSerializer.new(@user).serializable_hash
      }
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email)
    end
  end
end
