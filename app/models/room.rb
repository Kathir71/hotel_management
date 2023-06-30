class Room < ApplicationRecord
    validates :roomType , presence: true
    validates :cost , presence:true , numericality:true
    validates :totalAvailable , presence:true , numericality:{only_integer:true}
    validates :hotel_id , presence:true
    belongs_to :hotel
    has_many :bookings
    has_one_attached :roomImage
    validates :roomImage , presence:true , blob: { content_type: ['image/png', 'image/jpg', 'image/jpeg' , 'image/webp'], size_range: 1..(10.megabytes) }
end