class ManagersController < ApplicationController
    def signup
        @manager = Manager.new
    end

    def login
        @manager = Manager.new
    end

    def handleLogin
        loginEmail = params[:managers]["email"]
        loginPassword = params[:managers]["password"]
        @manager = Manager.where("email = ?" , loginEmail.downcase).where("password = ?" ,loginPassword).first
        puts @manager
        if @manager
            session[:manager_id] = @manager.id
            flash[:notice] = "Manager logged in successfully"
            redirect_to "/"
        else
            flash.now[:alert] = "Invalid credentials"
            render 'login'
        end
    end

    def handleSignup
        @manager = Manager.new(params.require(:managers).permit(:name , :employee_id , :phoneNumber , :email ,:password))
    if @manager.save
        session[:manager_id] =@manager.id
        flash[:notice] = "Manager Signed up successfully."
        redirect_to '/'
    else 
        render 'signup'
    end
    end
end