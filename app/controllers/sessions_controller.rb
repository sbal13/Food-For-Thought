class SessionsController < ApplicationController

	def welcome
		if logged_in?
			redirect_to posts_path
		else
			@scopes = "users:read,reminders:write,reminders:read,links:write,chat:write:bot"
			render :welcome
		end
	end


	def new
	end

	def create
		code = params[:code]

		signin_url = "https://slack.com/api/oauth.access?client_id=#{ENV['SLACK_KEY']}&client_secret=#{ENV['SLACK_SECRET']}&code=#{code}&redirect_uri=https://foodforthought-app.herokuapp.com/slack/auth"
		# signin_url = "https://slack.com/api/oauth.access?client_id=#{ENV['SLACK_KEY']}&client_secret=#{ENV['SLACK_SECRET']}&code=#{code}&redirect_uri=http://localhost:3000/slack/auth"
 		signin_data = JSON.parse(RestClient.get(signin_url))

 		redirect_to welcome_path unless signin_data["ok"]

 		slack_user_id = signin_data["user"]["id"]
 		@user = User.find_by(slack_id: slack_user_id)

		if @user
			session[:user_id] = @user.id
			redirect_to posts_path
		else
			initialize_new_user(signin_data["user"])
			render :'users/new'
		end
	end

	def destroy
		session.clear
		redirect_to welcome_path
	end

	def secret
		@user = User.find_by(id: params[:session][:id])
		session[:user_id] = @user.id
		redirect_to posts_path
	end

	private

	def initialize_new_user(params)
		@user = User.new(username: params["name"], email: params["email"], small_picture: params["image_48"], profile_picture: params["image_192"], slack_id: params["id"])
	end

	# def make_new_user(slack_user_id)

	# 	token = ENV['SLACK_TOKEN']
	# 	user_info_url = "https://slack.com/api/users.info?token=#{token}&user=#{slack_user_id}&pretty=1"
 # 		user_info = JSON.parse(RestClient.get(user_info_url))

 # 		username = user_info["user"]["name"]
 # 		first = user_info["user"]["profile"]["first_name"]
 # 		last = user_info["user"]["profile"]["last_name"]
 # 		email = user_info["user"]["email"]
 # 		small_picture = user_info["user"]["profile"]["image_48"]
 # 		profile_picture = user_info["user"]["profile"]["image_192"]

 # 		user_info = {
 # 			username: username,
 # 			first_name: first,
 # 			last_name: last,
 # 			email: email,
 # 			small_picture: small_picture,
 # 			profile_picture: profile_picture,
 # 			slack_id: slack_user_id}

 # 		@user = User.create(user_info)
	# end


end
