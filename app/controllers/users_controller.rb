class UsersController < ApplicationController
    before_action :require_not_manager
    before_action :require_user , only: [:dashboard , :logout]
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
            flash[:success] = "User logged in successfully"
            redirect_to "/"
        else
            render 'login'
        end
    end

    def handleSignup
        @user = User.new(params.require(:users).permit(:name , :email , :password))
    if @user.save
        session[:user_id] = @user.id
        flash[:success] = "User Signed up successfully."
        redirect_to '/'
    else 
        @user = User.new()
        render 'signup'
    end
    end

    def dashboard
        @pastBookings = Booking.joins(:hotel).select('bookings.* ,hotels.*').where("user_id = ?" , current_user.id).where("checkOutDate < ?" , Time.new.to_date).order(:checkInDate).paginate(:page =>params[:page] ,  :per_page => 5)
        @onGoingBookings = Booking.joins(:hotel).select('bookings.* ,hotels.*').where("user_id = ?" , current_user.id).where("checkInDate <= ?" , Time.new.to_date).where("checkOutDate >= ?" , Time.new.to_date).order(:checkInDate).paginate(:page => params[:page] , :per_page => 2)
        @futureBookings = Booking.joins(:hotel).select('bookings.* ,hotels.*').where("user_id = ?" , current_user.id).where("checkInDate > ?" , Time.new.to_date).order(:checkInDate).paginate(:page =>params[:page] ,  :per_page => 5)
    end

    def logout
    session[:user_id] = nil
    flash[:success] = "You have successfully logged out"
    redirect_to root_path    
    end

    private
    
  def require_user
    if !user_logged_in?
      flash[:danger] = "You need to be logged in to perform that action"
      redirect_to root_path
    end
  end

    def require_not_manager
        if manager_logged_in?
            flash[:danger] = "Manager can't access user paths"
            redirect_to root_path
        end
    end

end