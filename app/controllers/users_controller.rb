class UsersController < ApplicationController
    rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response
    wrap_parameters format: []

    before_action :authorized, only: [:show]

    def create
        user = User.create!(user_params)
        if user.valid?
            session[:user_id] = user.id 
            render json: user, status: :created 
        else 
            render json: {error: user.errors.full_messages}, status: :unprocessable_entity 
        end
    end

    def show
        current_user = User.find(session[:user_id])
        render json: current_user
    end 

    private
    def render_unprocessable_entity_response(invalid) 
        render json: {error: invalid.record.errors.full_messages}, status: :unprocessable_entity 
    end

    def user_params
        params.permit(:username, :password, :password_confirmation)
    end

    def authorized 
        return render json: {error: "Not authorized"}, status: :unauthorized unless session.include? :user_id 
      end

end
