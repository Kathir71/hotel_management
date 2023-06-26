class ManagersController < ApplicationController
    before_action :require_not_user 
    before_action :require_manager , only: [:dashboard]
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
            flash[:success] = "Manager logged in successfully"
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
        flash[:success] = "Manager Signed up successfully."
        redirect_to '/'
    else 
        render 'signup'
    end
    end

    def dashboard
        @hotel = current_manager.hotel;
        @hotelBookings = @hotel.bookings.joins(:user , :room).select('bookings.*' , 'users.*' , 'rooms.*');
    end

    def handleUserSearch
      query = params["queryEmail"].downcase 
      user = User.where("email = ?" , query).first
      @searchResults = Booking.joins(:user , :room).select('bookings.*' , 'users.*' , 'rooms.*').where("user_id = ?" , user.id)
      render 'search'
    #   respond_to do |format|
    #     format.js { render partial: 'managers/result' }
    #    end
    #   render json:{ partial: 'managers/result'}
    #   render json: { html: render_to_string(partial: 'managers/result') }
    end

    def logout
    session[:manager_id] = nil
    flash[:success] = "You have successfully logged out"
    redirect_to root_path    
    end

    private
    
    def require_not_user
        if user_logged_in?
            flash[:danger] = "User cannot access manager paths"
            redirect_to root_path
        end
    end

    def require_manager
        if !manager_logged_in?
            flash[:danger] = "Manager needs to be logged in"
            redirect_to hotelManager_login_path
        end
    end

end