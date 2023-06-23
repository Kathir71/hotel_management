class Hotel < ApplicationRecord
    belongs_to :manager
    has_many :rooms
    has_many :bookings
end