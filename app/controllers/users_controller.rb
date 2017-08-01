class UsersController < ApplicationController
	def new
		@user = User.new
	end

	def create
		@user = User.new(user_params)
		if @user.save
			session[:user_id] = @user.id
			redirect_to posts_path
		else
			flash[:message] = "Sign up failed"
			redirect_to new_user_path
		end
	end

	def edit
	end

	def update
	end

	def show
		@user = User.find_by(id: session[:user_id])
	end

	private
		def user_params
			params.require(:user).permit(:username, :first_name, :last_name, :slack, :email, :description, :cohort, :password, :password_confirmation)
		end
end