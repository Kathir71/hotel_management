class Room < ApplicationRecord
    validates :roomType , presence: true
    validates :cost , presence:true , numericality:true
    validates :totalAvailable , presence:true , numericality:{only_integer:true}
    validates :hotel_id , presence:true
    belongs_to :hotel
    has_many :bookings
    has_one_attached :roomImage
end