class Rating < ApplicationRecord
    belongs_to :booking
    validates :booking_id , presence:true , uniqueness:true
    validates :rating , presence:true , numericality:true
end