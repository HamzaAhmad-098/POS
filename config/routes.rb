# config/routes.rb
Rails.application.routes.draw do
  root 'dashboard#show'
  
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  get 'otp_login', to: 'sessions#otp_login'
  
  get 'dashboard', to: 'dashboard#show'
  
  resources :products do
    collection do
      get 'lookup'  
      get 'scan'
      post 'process_scan'
      get 'lookup'
      get 'fetch_details'
      get 'bulk_import'
      post 'bulk_import'
      get 'quick_add'
      post 'create_quick'
      get 'bulk_add_pakistani'
      post 'process_bulk_add'
    end
  end
  
  resources :sales do
    collection do
      get 'product_lookup'  # Add this route for barcode lookup
    end
    member do
      get 'receipt'
    end
  end
  
  resources :reports, only: [:index]
  resources :purchases
  resources :categories
  resources :customers
  
  namespace :admin do
    get 'dashboard', to: 'admin#dashboard'
    resources :shops
    resources :subscription_plans
    resources :tickets
  end
  # API endpoints for mobile app
  namespace :api do
    namespace :v1 do
      post 'auth/login', to: 'api_auth#login'
      get 'products/lookup', to: 'api_products#lookup'
      post 'sales', to: 'api_sales#create'
      get 'sales/:id/receipt', to: 'api_sales#receipt'
      get 'reports/daily', to: 'api_reports#daily'
    end
  end
end
