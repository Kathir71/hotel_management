class Manager < ApplicationRecord
 VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
 VALID_PHONE_REGEX = /\A(?:\+?\d{1,3}\s*-?)?\(?(?:\d{3})?\)?[- ]?\d{3}[- ]?\d{4}\z/

  before_save { self.email = email.downcase }
  validates :email, presence: true, 
                      uniqueness: { case_sensitive: false }, 
                      length: { maximum: 105 },
                      format: { with: VALID_EMAIL_REGEX }
  validates :name , presence: true
  validates :password_digest , presence: true , length: {minimum:8}
  validates :phoneNumber , presence: true , length:{minimum:7 , maximum:10},format: {with: VALID_PHONE_REGEX}

  has_one :hotel
  has_secure_password
end