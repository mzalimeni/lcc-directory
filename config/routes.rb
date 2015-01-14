LccDirectory::Application.routes.draw do


  root 'directory#home'

  match '/admin',                     to: 'admin#home',               via: 'get'
  match '/download',                  to: 'admin#download',           via: 'get'
  match '/upload',                    to: 'admin#upload',             via: 'get'
  match '/admin/registration/open',   to: 'admin#open_registration',  via: 'post'
  match '/admin/registration/close',  to: 'admin#close_registration', via: 'get'
  get 'admin/home'
  get 'admin/download'
  get 'admin/upload'
  post 'admin/import'
  get 'admin/registration'

  match '/all',       to: 'users#all',            via: 'get'
  match '/search',    to: 'users#search', 	      via: 'get'
  
  resources :users
  resources :children

  match '/users/:id/child/new',  to: 'children#new',          via: 'get', as: 'user_new_child'
  match '/children/promote/:id', to: 'children#promote',      via: 'get', as: 'promote'
  match '/edit/cancel',          to: 'sessions#cancel_edit',  via: 'get', as: 'cancel_edit'

  resources :sessions, only: [:new, :create, :destroy]
  match '/signin',  to: 'sessions#new',         via: 'get'
  match '/signout', to: 'sessions#destroy',     via: 'delete'
  
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
