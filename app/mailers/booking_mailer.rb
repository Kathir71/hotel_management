class BookingMailer < ApplicationMailer
    def new_booking_mailer
    @order = params[:order]
    @user = params[:user]
    @hotel = params[:hotel]
    @booking = params[:booking_details]
    debugger
    mail(to: @user.email, subject: "Congrats on booking in book easy")
  end
end
