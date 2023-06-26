class PagesController < ApplicationController
    before_action :not_require_user , only: [:chooseSignup , :chooseLogin]
    def home
    end

    def chooseSignup
    end

    def chooseLogin
    end
    private
    def not_require_user
        #neither manager or user must be logged in
        if user_logged_in? || manager_logged_in?
            flash[:danger] = "Already logged in , logout to continue"
            redirect_to root_path
        end
    end
end