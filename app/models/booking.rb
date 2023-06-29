class Booking < ApplicationRecord
    validates :roomType , presence:true
    validates :numRoomsBooked , presence:true , numericality: { only_integer: true }
    validates :price , presence:true , numericality: true
    validates :checkInDate , presence:true
    validates :checkOutDate , presence:true
    # validates :isCancelled , presence:true
    validates :user_id , presence:true
    validates :room_id , presence:true
    validates :hotel_id , presence:true
    belongs_to :user 
    belongs_to :hotel
    belongs_to :room
    has_one :rating
end