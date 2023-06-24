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

  get '/hotelManager/login', to: "managers#login"
  get '/hotelManager/signup', to: "managers#signup"
  post '/hotelManager/login', to: "managers#handleLogin"
  post '/hotelManager/signup', to: "managers#handleSignup"


  get '/hotel/create', to:"hotels#create"
  post '/hotel/handleCreate' , to:"hotels#handleCreate"
  post '/hotel/search', to:"hotels#search"
  post '/hotel/book', to:"hotels#book"
  post '/hotel/handleBooking' , to:"hotels#handleBooking"

end
