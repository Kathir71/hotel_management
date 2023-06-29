class ManagersController < ApplicationController
    before_action :require_not_user 
    before_action :require_manager , only: [:dashboard , :handleUserSearch , :handleIntervalSearch , :logout]
    def signup
        @manager = Manager.new
    end

    def login
        @manager = Manager.new
    end

    def handleLogin
        loginEmail = params[:managers]["email"]
        loginPassword = params[:managers]["password"]
        @manager = Manager.where("email = ?" , loginEmail.downcase).first
        if @manager && @manager.authenticate(loginPassword)
            session[:manager_id] = @manager.id
            flash[:success] = "Manager logged in successfully"
            redirect_to "/"
        else
            flash.now[:danger] = "Invalid credentials"
            render 'login'
        end
    end

    def handleSignup
        email = params[:managers]["email"]
        userExist = User.where("email = ?" , email).first;
        if userExist
            flash.now[:danger] = "You are already a user here.Use a seperate account for manager"
            @manager = Manager.new();
            render 'signup'
            return
        end
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
        @hotelBookings = @hotel.bookings.joins(:user , :room).select('bookings.*' , 'users.*' , 'rooms.*').order(checkInDate: :desc);
    end

    def handleUserSearch
      query = params[:query]["queryEmail"].downcase 
      user = User.where("email = ?" , query).first
      @searchResults = Booking.joins(:user , :room).select('bookings.*' , 'users.*' , 'rooms.*').where("user_id = ?" , user.id).where("bookings.hotel_id = ?" , current_manager.hotel.id).order(checkInDate: :desc)
      render 'search'
    #   respond_to do |format|
    #     format.js { render partial: 'managers/result' }
    #    end
    #   render json:{ partial: 'managers/result'}
    #   render json: { html: render_to_string(partial: 'managers/result') }
    end

    def handleIntervalSearch

        checkInDate = params[:query]["checkInDate"]
        checkOutDate = params[:query]["checkOutDate"]
        @hotel = current_manager.hotel;
        if checkInDate == "" && checkOutDate ==""
            @searchResults = @hotel.bookings.joins(:user , :room).select('bookings.*' , 'users.*' , 'rooms.*').where("bookings.hotel_id = ?" ,@hotel.id );
        elsif checkInDate == ""
            #users leaving before a given date
            @searchResults = @hotel.bookings.joins(:user , :room).select('bookings.*' , 'users.*' , 'rooms.*').where("checkOutDate <= ?" , checkOutDate.to_date).order(:checkInDate).where("bookings.hotel_id = ?" , @hotel.id);

        elsif checkOutDate == ""
            #users arriving after a certain date
            @searchResults = @hotel.bookings.joins(:user , :room).select('bookings.*' , 'users.*' , 'rooms.*').where("checkInDate >= ?" , checkInDate.to_date).order(:checkInDate).where("bookings.hotel_id = ?"  ,@hotel.id)

        else
            #users in the interval
            @searchResults = @hotel.bookings.joins(:user , :room).select('bookings.*' , 'users.*' , 'rooms.*').where("checkInDate >= ?" , checkInDate.to_date).where("checkOutDate <= ?" , checkOutDate.to_date).where("hotel_id = ?" , @hotel.id).order(:checkInDate)
        end
      render 'search'
        
    end

    def logout
    session[:manager_id] = nil
    flash[:success] = "You have successfully logged out"
    redirect_to root_path    
    end

    def edit
        @hotel = current_manager.hotel
        @rooms = @hotel.rooms
    end

    def update
        roomId = params[:room]["id"].to_i
        newCost = params[:room]["cost"].to_f
        if  newCost <= 0
            flash[:danger] = "Invalid cost provided"
            redirect_to hotelManager_dashboard_path
            return
        end
        @room = Room.find(roomId)
        @room.cost = newCost
        @hotel = current_manager.hotel
        @rooms = @hotel.rooms
        if @room.save
            flash.now[:success] = "Room price has been updated"
            render 'edit'
        else
            flash.now[:danger] = "Invalid cost provided"
            render 'edit'
        end
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