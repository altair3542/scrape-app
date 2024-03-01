Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
# config/routes.rb
  resources :businesses do
    collection do
      post 'scrape_and_save'
      get 'new_manual_entry'
      post 'create_manual_entry'
      get 'new_excel_upload'
      post 'create_excel_upload'
      get 'export_to_excel'
      post :scrape_websites_and_phone_numbers
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
