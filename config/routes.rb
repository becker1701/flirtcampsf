Rails.application.routes.draw do

  # You can have the root of your site routed with "root"
  root 'static_pages#home'

# sessions
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

# static pages
  get 'about', to: 'static_pages#about'
  get 'contact', to: 'static_pages#contact'
  get 'signup', to: 'users#new'
  get 'new_member_app', to: 'static_pages#new_member_app'

  # resources :change_status, only: [:edit, :update]

  # get 'food_restrictions', to: 'users#food_restrictions'

  patch 'set_added_to_google_group/:id', to: 'users#added_to_google_group', as: 'set_added_to_google_group'

  resources :users do
    resources :user_notes
    resources :payments
    get 'camp_dues_notification', on: :member
    collection do
      get 'food_restrictions', to: 'users#food_restrictions'
    end
  end

  resources :membership_applications, only: [:index, :new, :create, :edit, :destroy] do
    member do
      get 'thank_you'
      get 'approve'
      get 'decline'
      get 'archive'
    end
  end
  resources :verify_tickets, only: :edit
  resources :existing_member_requests, only: [:new, :create]
  resources :account_activations, only: [:new, :create, :edit]
  resources :password_resets, only: [:new, :create, :edit, :update]
  resources :invitations, only: [:new, :create, :edit, :update, :destroy] do
    member do
      get 'resend'
    end

    collection do
      get 'resend_all'
    end
  end


  resources :events do
    resources :storage_tenents, only: :index
    resources :activities
    resources :intentions, only: [:create, :edit, :update] do
      patch :edit_storage_tenent, on: :member
    end
    resources :early_arrivals, only: [:index, :edit, :update, :create, :destroy]
    resources :tickets, only: [:new, :create, :show, :index, :edit, :destroy]
    member do
      get 'camp_dues_overview'
    end

  end
end
