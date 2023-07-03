class BookingMailer < ApplicationMailer
    def new_booking_mailer
    @user = params[:user]
    @hotel = params[:hotel]
    @booking = params[:booking_details]
    mail(to: @user.email, subject: "Hurray ! Your rooms are booked.Congrats on booking in book easy")
  end
end
