class Room < ApplicationRecord
    validates :roomType , presence: true
    validates :cost , presence:true , numericality:true
    validates :totalAvailable , presence:true , numericality:{only_integer:true}
    belongs_to :hotel
    has_many :bookings
end