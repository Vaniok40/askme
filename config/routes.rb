Rails.application.routes.draw do
  root 'feed#index'
  get 'feed', to: 'feed#index', as: :feed

  resources :users do
    member do
      patch :disable
      patch :enable
    end
  end
  resources :sessions, only: [:new, :create, :destroy]
  resources :questions, except: [:show, :new, :index]
  resources :tags, param: :name, only: [:show]

  resources :posts, only: [:new, :create, :show, :edit, :update, :destroy] do
    resources :comments, only: [:create, :destroy]
    member do
      post :toggle_like
    end
  end

  post   'interests/:tag_id', to: 'user_interests#create',  as: :follow_tag
  delete 'interests/:tag_id', to: 'user_interests#destroy', as: :unfollow_tag

  get 'sign_up' => 'users#new'
  get 'log_in'  => 'sessions#new'
  get 'log_out' => 'sessions#destroy'
end
