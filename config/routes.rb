Rails.application.routes.default_url_options[:host] = 'http://localhost:3000'
Rails.application.routes.draw do
  use_doorkeeper
  devise_for :users, controllers: {sessions: 'sessions', registrations: 'registrations', :omniauth_callbacks => "omniauth_callbacks" }

  mount RedactorRails::Engine => '/redactor_rails'

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  root "questions#index"
  post "/widget", controller: :application, action: :widget_data
  get "/search", to: "search#index"

  concern :commentable do
    resources :comments
  end

  concern :rating do
    post :rate
  end

  resources :categories
  resources :users, except: [:new, :create]
  resources :questions, concerns: [:commentable, :rating] do
    collection do
      post :filter
      get :tag
    end
    post :sign_in_question, on: :member
    resources :answers, concerns: [:commentable, :rating] do
      post :helpfull, on: :member
    end
  end

  namespace :admin do
    resources :categories
  end

  namespace :api do
    namespace :v1 do
      resources :profiles do
        get :me, on: :collection
      end
      resources :questions do
        resources :answers
      end
    end
  end
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
