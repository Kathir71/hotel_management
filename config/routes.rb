Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root "pages#home"
  get '/signUp', to: "pages#chooseSignup"
  get '/login', to: "pages#chooseLogin"

  get '/user/login', to: "users#login" 
  get '/user/signup', to: "users#signup"
  get '/user/dashboard', to: "users#dashboard"
  post '/user/login', to: "users#handleLogin"
  post '/user/signup', to: "users#handleSignup"
  delete '/user/logout', to:"users#logout"
  post '/user/rate', to:"users#ratings"

  get '/hotelManager/login', to: "managers#login"
  get '/hotelManager/signup', to: "managers#signup"
  get '/hotelManager/dashboard', to:"managers#dashboard"
  post '/hotelManager/login', to: "managers#handleLogin"
  post '/hotelManager/signup', to: "managers#handleSignup"
  post '/hotelManager/search', to: "managers#handleUserSearch"
  post '/hotelManager/intervalSearch', to: "managers#handleIntervalSearch"
  delete '/hotelManager/logout', to:"managers#logout"


  get '/hotel/create', to:"hotels#create"
  post '/hotel/handleCreate' , to:"hotels#handleCreate"
  post '/hotel/search', to:"hotels#search"
  post '/hotel/book', to:"hotels#book"
  post '/hotel/handleBooking' , to:"hotels#handleBooking"

end
