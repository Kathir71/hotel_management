class Hotel < ApplicationRecord
    validates :name , presence:true
    validates :address , presence:true
    validates :description , presence:true
    belongs_to :manager
    has_many :rooms
    has_many :bookings
end