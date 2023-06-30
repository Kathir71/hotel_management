class CancelMailer < ApplicationMailer
    def cancel_booking_mailer
        @user = params[:user]
        @hotel = params[:hotel]
        @booking = params[:booking_details]
        @manager = params[:manager]
        mail(to: @user.email, subject: "Tickets cancelled.")

    end
end
