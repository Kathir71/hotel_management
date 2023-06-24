class UsersController < ApplicationController
    before_action :require_user , only: [:dashboard]
    def signup
        @user = User.new
    end

    def login
        @user = User.new
    end

    def handleLogin
        loginEmail = params[:users]["email"]
        loginPassword = params[:users]["password"]
        @user = User.where("email = ?" , loginEmail.downcase).where("password = ?" ,loginPassword).first
        if @user
            session[:user_id] = @user.id
            flash[:notice] = "User logged in successfully"
            redirect_to "/"
        else
            render 'login'
        end
    end

    def handleSignup
        puts "hii"
        @user = User.new(params.require(:users).permit(:name , :email , :password))
    if @user.save
        session[:user_id] = @user.id
        flash[:notice] = "User Signed up successfully."
        redirect_to '/'
    else 
        render 'signup'
    end
    end

    def dashboard
        @userBookings = current_user.bookings
    end

    private
    
    def require_user
    if !user_logged_in?
      flash[:danger] = "You need to be logged in to perform that action"
      redirect_to root_path
    end
  end
end