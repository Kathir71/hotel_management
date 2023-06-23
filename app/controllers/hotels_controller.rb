class HotelsController < ApplicationController
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
            for i in 1..numRooms do
            @room = Room.new()
            @room.roomType = roomTypes[i-1]
            @room.cost = roomCosts[i-1]
            @room.totalAvailable = roomAvailables[i-1]
            @room.hotel_id = @hotel.id
            @room.save
            end
            flash[:notice] ="Hotels and rooms created successfully"
            redirect_to '/'
        else
            render 'create'
        end
    end

    def search
        query = params[:query]["query"]
        checkInDate = params[:query]["checkInDate"]
        checkOutDate = params[:query]["checkOutDate"]
        @hotels = Hotel.where("name LIKE ?" , "%" + query + "%").or(Hotel.where("address LIKE ?" , "%" + query + "%"))
        @finalArr = []
        @hotels.each do |hotel|
            combinedObj = Hash.new()
            combinedObj["hotel"] = hotel
            combinedObj["rooms"] = Room.where("hotel_id = ?" , hotel.id);
            combinedObj["manager"] = Manager.find(hotel.manager_id)
            roomAvailability = checkAvailability(combinedObj["rooms"] , checkInDate , checkOutDate)
            combinedObj["availability"] = roomAvailability
            @finalArr << combinedObj
        end
        render 'search'
    end
    private
    def checkAvailability (rooms , checkInDate , checkOutDate)
        availabilityArray = []
        rooms.each do |room|
            bookingsInInterval = Booking.where("room_id = ?" , room.id).where("checkInDate >= ?" , checkInDate).where("checkInDate <= ?" , checkOutDate).or(
                Booking.where("checkOutDate >= ?" , checkInDate ).where("checkOutDate <= ?" ,checkOutDate )
            )
            numBooked = 0
            bookingsInInterval.each do |booking|
                numBooked += booking.numRoomsBooked
        end
            availabilityArray << room.totalAvailable - numBooked
        end
        return availabilityArray
    end
end