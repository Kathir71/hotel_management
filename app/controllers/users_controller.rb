class UsersController < ApplicationController
    before_action :require_not_manager
    before_action :require_user , only: [:dashboard , :logout , :cancelBooking , :ratings]
    before_action :require_user_booking , only: [:cancelBooking]
    before_action :require_user_rating , only: [:ratings]
    def signup
        @user = User.new
    end

    def login
        @user = User.new
    end

    def handleLogin
        loginEmail = params[:users]["email"]
        loginPassword = params[:users]["password"]
        @user = User.where("email = ?" , loginEmail.downcase).first
        if @user && @user.authenticate(loginPassword)
            session[:user_id] = @user.id
            flash[:success] = "User logged in successfully"
            redirect_to "/"
        else
            flash.now[:danger] = "Invalid credentials";
            render 'login'
        end
    end

    def handleSignup
        email = params[:users]["email"]
        @user = User.new(params.require(:users).permit(:name , :email , :password , :avatar))
        managerExist = Manager.where("email = ?" , email).first
        if managerExist
            @user = User.new()
            flash.now[:danger] = "You are a manager here."
            render 'signup'
            return;
        end
    if @user.save
        session[:user_id] = @user.id
        flash[:success] = "User Signed up successfully."
        redirect_to '/'
        return
    else 
        render 'signup'
    end
    end

    def dashboard
        @pastBookings = Booking.joins(:hotel).select('bookings.id , bookings.user_id , bookings.hotel_id , bookings.roomType , bookings.numRoomsBooked , bookings.price , bookings.checkInDate , bookings.checkOutDate , bookings.isCancelled , hotels.name').where("user_id = ?" , current_user.id).where("isCancelled = ?" , false).where("checkOutDate < ?" , Time.new.to_date).order(:checkInDate).paginate(:page =>params[:page] ,  :per_page => 3)
        @onGoingBookings = Booking.joins(:hotel).select('bookings.id , bookings.user_id , bookings.hotel_id , bookings.roomType , bookings.numRoomsBooked , bookings.price , bookings.checkInDate , bookings.checkOutDate , bookings.isCancelled , hotels.name').where("user_id = ?" , current_user.id).where("isCancelled = ?" , false).where("checkInDate <= ?" , Time.new.to_date).where("checkOutDate >= ?" , Time.new.to_date).order(:checkInDate).paginate(:page => params[:page] , :per_page => 3)
        @futureBookings = Booking.joins(:hotel).select( 'bookings.id , bookings.user_id , bookings.hotel_id , bookings.roomType , bookings.numRoomsBooked , bookings.price , bookings.checkInDate , bookings.checkOutDate , bookings.isCancelled , hotels.name').where("user_id = ?" , current_user.id).where("isCancelled = ?" , false).where("checkInDate > ?" , Time.new.to_date).order(:checkInDate).paginate(:page =>params[:page] ,  :per_page => 3)
        @bookings = current_user.bookings.joins(:rating).select('bookings.id , ratings.rating') #rated bookings
        @cancelledBookings = Booking.joins(:hotel).select( 'bookings.id , bookings.user_id , bookings.hotel_id , bookings.roomType , bookings.numRoomsBooked , bookings.price , bookings.checkInDate , bookings.checkOutDate , bookings.isCancelled , hotels.name').where('user_id = ?' , current_user.id).where('isCancelled = ?' , true).order(:checkInDate).paginate(:page =>params[:page] ,  :per_page => 3);
    end

    def edit
        @user = current_user
    end

    def update

    end

    def cancelBooking
        toCancelId = params[:bookingDetails]["bookingId"];
        reqBooking = Booking.find(toCancelId)
        reqBooking.isCancelled = true
        if reqBooking.save
            @pastBookings = Booking.joins(:hotel).select('bookings.id , bookings.user_id , bookings.hotel_id , bookings.roomType , bookings.numRoomsBooked , bookings.price , bookings.checkInDate , bookings.checkOutDate , bookings.isCancelled , hotels.name').where("user_id = ?" , current_user.id).where("checkOutDate < ?" , Time.new.to_date).order(:checkInDate).paginate(:page =>params[:page] ,  :per_page => 3)
            @onGoingBookings = Booking.joins(:hotel).select('bookings.id , bookings.user_id , bookings.hotel_id , bookings.roomType , bookings.numRoomsBooked , bookings.price , bookings.checkInDate , bookings.checkOutDate , bookings.isCancelled , hotels.name').where("user_id = ?" , current_user.id).where("checkInDate <= ?" , Time.new.to_date).where("checkOutDate >= ?" , Time.new.to_date).order(:checkInDate).paginate(:page => params[:page] , :per_page => 3)
            @futureBookings = Booking.joins(:hotel).select( 'bookings.id , bookings.user_id , bookings.hotel_id , bookings.roomType , bookings.numRoomsBooked , bookings.price , bookings.checkInDate , bookings.checkOutDate , bookings.isCancelled , hotels.name').where("user_id = ?" , current_user.id).where("checkInDate > ?" , Time.new.to_date).order(:checkInDate).paginate(:page =>params[:page] ,  :per_page => 3)
            @bookings = current_user.bookings.joins(:rating).select('bookings.id , ratings.rating') #rated bookings
            @cancelledBookings = Booking.joins(:hotel).select( 'bookings.id , bookings.user_id , bookings.hotel_id , bookings.roomType , bookings.numRoomsBooked , bookings.price , bookings.checkInDate , bookings.checkOutDate , bookings.isCancelled , hotels.name').where('user_id = ?' , current_user.id).where('isCancelled = ?' , true).order(:checkInDate).paginate(:page =>params[:page] ,  :per_page => 3);
            flash.now[:success] = "Booking cancelled successfully"
            render 'dashboard'
        else
            flash[:danger] = "Internal server error"
            redirect_to root_path
        end
    end

    def logout
    session[:user_id] = nil
    flash[:success] = "You have successfully logged out"
    redirect_to root_path    
    end

    def ratings
        ratingVal = params[:rating]["rating"];
        if ratingVal.to_i <= 0 || ratingVal.to_i > 5
            flash[:danger] = "Invalid rating values"
            redirect_to user_dashboard_path
            return
        end

        @rating = Rating.new(params.require(:rating).permit(:booking_id , :rating));
        if @rating.save
            flash[:success] = "Thanks for your feedback"
            redirect_to '/user/dashboard'
            return
        else
            flash[:danger] = "Internal server error"
            redirect_to root_path
        end
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

    def require_user_booking
        if user_logged_in?
            bookings = current_user.bookings
            doesExist = bookings.find{|booking| booking.id == params[:bookingDetails]["bookingId"].to_i}
            if !doesExist
                flash[:danger] = "You are not authorised to cancel this booking"
                redirect_to root_path
            elsif doesExist.isCancelled == true
                flash[:danger] = "Already cancelled booking"
                redirect_to root_path
            end
        else
            flash[:danger] = "Unauthorised"
            redirect_to root_path
        end
    end

    def require_user_rating
        bookings = current_user.bookings
        doesExist = bookings.find{|booking| booking.id == params[:rating]["booking_id"].to_i}
        if !doesExist
            flash[:danger] = "Unauthorised"
            redirect_to root_path
        end
    end

end