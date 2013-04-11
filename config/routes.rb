LdrWip::Application.routes.draw do
  ActiveAdmin.routes self

  devise_for :users, :skip => :registrations

  root :to => 'news#index'

  resources :users, :except => :destroy, :path_names => {:new => :sign_up} do
    get :autocomplete, :as => :autocomplete, :on => :collection, :path => :autocomplete
    resources :ratings, :only => :index
  end

  resources :pages, :only => [:index, :show]
  resource  :token, :only => :show

  with_options :except => [:index, :show] do |comments|
    resources :games, :except => [:edit, :update, :destroy] do
      comments.resources :comments
      resource :issue, :only => :create

      collection do
        get :autocomplete_map,     :as => :autocomplete_map,     :path => :autocomplete_map
        get :autocomplete_faction, :as => :autocomplete_faction, :path => :autocomplete_faction
        get :autocomplete_leader,  :as => :autocomplete_leader,  :path => :autocomplete_leader
        get :suggestions, :constraints => {:format => :json}
      end

      member do
        get  :download
        post :parse
        post :revoke
      end
    end

    resources :news, :only => [:index, :show] do
      comments.resources :comments
      resource :issue, :only => :create
    end
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
