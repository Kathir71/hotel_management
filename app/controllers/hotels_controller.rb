class HotelsController < ApplicationController
    before_action :require_manager , only: [:create , :handleCreate]
    before_action :require_user , only: [:book , :handleBooking]
    before_action :require_valid_dates , only:[:search]

    def create
        @hotel = Hotel.new
    end

    def handleCreate
        @hotel = Hotel.new(params.require(:custom).permit(:name , :address , :description))
        @hotel.manager_id = current_manager.id
        if @hotel.save
            numRooms = params["roomType"].length 
            roomTypes = params["roomType"]
            roomCosts = params["roomCost"]
            roomAvailables = params["roomAvailable"]
            roomImages = params["roomImages"]
            for i in 1..numRooms do
            @room = Room.new()
            @room.roomType = roomTypes[i-1]
            @room.cost = roomCosts[i-1]
            @room.totalAvailable = roomAvailables[i-1]
            @room.hotel_id = @hotel.id
            @room.roomImage = roomImages[i-1]
            if !@room.save
                flash[:danger] = "Room data not valid";
            end
            end
            flash[:success] ="Hotels and rooms created successfully"
            redirect_to '/'
        else
            render 'create'
        end
    end

    def search
        query = params[:query]["query"].downcase
        @checkInDate = params[:query]["checkInDate"]
        @checkOutDate = params[:query]["checkOutDate"]
        @hotels = Hotel.where("lower(name) LIKE ?" , "%" + query + "%").or(Hotel.where("lower(address) LIKE ?" , "%" + query + "%"))
        @finalArr = []
        @hotels.each do |hotel|
            combinedObj = Hash.new()
            combinedObj["hotel"] = hotel
            combinedObj["rooms"] = Room.where("hotel_id = ?" , hotel.id);
            combinedObj["manager"] = Manager.find(hotel.manager_id)
            combinedObj["ratings"] = Rating.joins(:booking).select('bookings.* , ratings.*').where('bookings.hotel_id = ?' , hotel.id);
            roomAvailability = checkAvailability(combinedObj["rooms"] , @checkInDate , @checkOutDate)
            #associate rating with hotel or the room??
            combinedObj["availability"] = roomAvailability
            if combinedObj["ratings"].length != 0 
                avgRating = 0
                combinedObj["ratings"].each do |rating|
                     avgRating += rating.rating.to_i
                end
                combinedObj["avgRating"] = avgRating.to_f / combinedObj["ratings"].length
            else
                combinedObj["avgRating"] = "No ratings available"
            end
            @finalArr << combinedObj
        end
        #filters
        onlyAvailable = params[:query]["onlyAvailable"].to_i
        sortByprice = params[:query]["sortByprice"].to_i
        sortByAvailability = params[:query]["sortByAvailability"].to_i
        sortByRating = params[:query]["sortByRating"].to_i
        if onlyAvailable == 1
            @finalArr = filter_only_available(@finalArr)
        end

        if sortByprice == 1
            @finalArr = sort_based_on_cost(@finalArr)
        end

        if sortByAvailability == 1
            @finalArr = sort_based_on_availability(@finalArr)
        end

        if sortByRating == 1
            @finalArr = sort_based_on_rating(@finalArr)
        end

        lowerBound = params[:query]["lowerBound"]
        if (lowerBound == "")
            lowerBound = 0
        else 
            lowerBound = lowerBound.to_i
        end
        upperBound = params[:query]["upperBound"]
        if (upperBound == "")
            upperBound = 999999999999;
        else
            upperBound = upperBound.to_i 
        end

        @finalArr = filter_based_on_cost(@finalArr , lowerBound , upperBound);

        render 'search'
    end

    def book
    @room = Hash.new()
    @room["roomType"] = params[:roomDetails][:roomType]
    @room["roomCost"]= params[:roomDetails][:roomCost]
    @room["availability"] = params[:roomDetails][:availability]
    @room["roomId"] = params[:roomDetails][:roomId]
    @checkInDate = params[:roomDetails][:checkInDate]
    @checkOutDate = params[:roomDetails][:checkOutDate]
    @hotelId = params[:roomDetails][:hotelId]
    @roomImage = Room.find(@room["roomId"]).roomImage
    @hotel = Hotel.find(@hotelId);
    render 'book'
    end

    def handleBooking
        checkInDate = params[:booking][:checkInDate].to_date
        checkOutDate = params[:booking][:checkOutDate].to_date
        numDaysStay = (checkOutDate - checkInDate).to_i + 1
        userRequest = params[:booking][:numRoomsBooked].to_i
        @booking = Booking.new()
        @booking.user_id = current_user.id
        @booking.room_id = params[:booking][:roomId]
        @booking.hotel_id = params[:booking][:hotelId]
        @booking.price = numDaysStay * params[:booking][:roomCost].to_i * params[:booking][:numRoomsBooked].to_i
        @booking.numRoomsBooked = userRequest
        @booking.checkInDate = checkInDate
        @booking.checkOutDate = checkOutDate
        @booking.isCancelled = false
        @booking.roomType = params[:booking][:roomType]
        numAvailable = check_room_availability(@booking.room_id , checkInDate , checkOutDate)
        #do check availability here again
        if userRequest > numAvailable
            flash[:danger] = "Your request is higher than the rooms available"
            redirect_to root_path
            return
        end
       if @booking.save
            BookingMailer.with(user:current_user , hotel:Hotel.find(@booking.hotel_id) , booking_details:@booking).new_booking_mailer.deliver_later
            flash[:success] = "Rooms booked successfully"
            redirect_to root_path
        else
            # debugger
            flash[:danger] = "Some error has happened"
            redirect_to root_path
        end
    end
    private
    def checkAvailability (rooms , checkInDate , checkOutDate)
        availabilityArray = []
        rooms.each do |room|
            bookingsInInterval = Booking.where("room_id = ?" , room.id).where("checkInDate >= ?" , checkInDate).where("checkInDate <= ?" , checkOutDate).or(
                Booking.where("checkOutDate >= ?" , checkInDate ).where("checkOutDate <= ?" ,checkOutDate ).where("room_id = ?" , room.id).or(
                    Booking.where("room_id = ?" , room.id).where("checkInDate <= ?" , checkInDate).where("checkOutDate >= ?" , checkOutDate)
                )
            )
            numBooked = 0
            bookingsInInterval.each do |booking|
                numBooked += booking.numRoomsBooked
            end
            availabilityArray << room.totalAvailable - numBooked
        end
        return availabilityArray
    end

    def check_room_availability(roomId , checkInDate , checkOutDate)
            bookingsInInterval = Booking.where("room_id = ?" , roomId).where("checkInDate >= ?" , checkInDate).where("checkInDate <= ?" , checkOutDate).or(
                Booking.where("checkOutDate >= ?" , checkInDate ).where("checkOutDate <= ?" ,checkOutDate ).where("room_id = ?" , roomId).or(
                    Booking.where("room_id = ?" , roomId).where("checkInDate <= ?" , checkInDate).where("checkOutDate >= ?" , checkOutDate)
                )
            )
            numBooked = 0
            bookingsInInterval.each do |booking|
                numBooked += booking.numRoomsBooked
            end
            room = Room.find(roomId)
            return room.totalAvailable - numBooked
    end

    def within_price? (obj , lowerBound  , upperBound )
        val = false
        obj["rooms"].each do |room|
            # debugger
            if room.cost >= lowerBound && room.cost <= upperBound
                val = true
            end
        end
        val
    end

    def available? (obj)
        val = false
        obj["availability"].each do |singleAvailability|
            if singleAvailability != 0
                val = true
            end
        end
        val
    end

    def sort_based_on_availability( arr)
        arr.sort! do |x , y|
            xtotalAvailability = 0
            x["availability"].each do |singleRoomAvailability|
                xtotalAvailability += singleRoomAvailability
            end
            ytotalAvailability = 0
            y["availability"].each do |singleRoomAvailability|
                ytotalAvailability += singleRoomAvailability
            end

            if xtotalAvailability > ytotalAvailability
                -1
            elsif xtotalAvailability < ytotalAvailability
                1
            else
                0
            end

        end
        arr
    end

    def sort_based_on_cost(arr)
        arr.sort! do |x , y|
            xMinCost = 999999999999
            yMinCost = 999999999999
            x["rooms"].each do |room|
                if room.cost < xMinCost 
                    xMinCost = room.cost
                end
            end

            y["rooms"].each do |room|
                if room.cost < yMinCost
                    yMinCost = room.cost
                end
            end

            if xMinCost > yMinCost
                1
            elsif xMinCost < yMinCost
                -1
            else
                0
            end
        end
        arr
    end

    def sort_based_on_rating(arr)
        arr.sort! do |x , y|
            #average rating of all rooms of the hotel 
            xAvg = 0
            yAvg = 0
            xSum = 0;
            xNum = x["ratings"].length
            x["ratings"].each do |rating|
                xSum += rating.rating.to_i
            end
            if xNum != 0
            xAvg = xSum / xNum
            end
            ySum = 0;
            yNum = y["ratings"].length
            y["ratings"].each do |rating|
                ySum += rating.rating.to_i
            end
            if yNum != 0
            yAvg = ySum / yNum
            end

            if xAvg > yAvg
                -1
            elsif xAvg < yAvg
                1
            else
                0
            end
        end
        arr
    end

    def filter_based_on_cost(arr , lowerBound = 0 , upperBound = 999999999)
            arr.select { |obj| within_price?(obj , lowerBound , upperBound)}
    end

    def filter_only_available ( arr)
        arr.select {|obj| available?(obj)}
    end

     def require_user
        if !user_logged_in?
            flash[:danger] = "You need to be logged in to perform that action"
            redirect_to user_login_path
        end
     end

     def require_manager
        if !manager_logged_in?
            flash[:danger] = "You need to be a manager"
            redirect_to hotelManager_login_path
        end
     end

     def require_valid_dates
        @checkInDate = params[:query]["checkInDate"]
        @checkOutDate = params[:query]["checkOutDate"]
        currentDate = Time.new.to_date
        if !(@checkInDate.to_date >= currentDate && @checkOutDate >= @checkInDate)
            flash[:danger] = "Invalid dates"
            redirect_to root_path
        end
     end

end