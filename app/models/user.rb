class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  before_save { self.email = email.downcase }

  validates :email, presence: true, 
                      uniqueness: { case_sensitive: false }, 
                      length: { maximum: 105 },
                      format: { with: VALID_EMAIL_REGEX }
  validates :name , presence: true
  validates :password_digest , presence: true , length: {minimum: 8}
  validates :avatar , presence:true , blob: { content_type: ['image/png', 'image/jpg', 'image/jpeg' , 'image/webp'], size_range: 1..(5.megabytes) }
  has_many :bookings
  has_one_attached :avatar
  has_secure_password
end
