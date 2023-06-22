class UsersController < ApplicationController
    def signup
        @user = User.new
    end

    def login
        @user = User.new
    end

    def handleLogin
        loginEmail = params[:users]["email"]
        loginPassword = params[:users]["password"]
        @user = User.where("email = ?" , loginEmail).where("password = ?" ,loginPassword)
        puts @user
        if @user
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
        flash[:notice] = "User Signed up successfully."
        redirect_to '/'
    else 
        render 'signup'
    end
    end
end