Rails.application.routes.draw do
  root 'feed#index'
  get 'feed', to: 'feed#index', as: :feed

  resources :users do
    member do
      patch :disable
      patch :enable
    end
  end
  resources :sessions, only: %i[new create destroy]
  resources :tags, param: :name, only: [:show] do
    collection { get :search }
  end

  resources :posts, only: %i[new create show edit update destroy] do
    resources :comments, only: %i[create destroy]
    member do
      post :toggle_like
    end
    collection do
      get :my_posts
    end
  end

  post   'interests/:tag_id', to: 'user_interests#create',  as: :follow_tag
  delete 'interests/:tag_id', to: 'user_interests#destroy', as: :unfollow_tag

  resources :conversations, only: %i[index create] do
    member do
      get :messages
    end
    resources :messages, only: [:create] do
      collection do
        get :poll
      end
    end
  end
  get 'messages/unread_count', to: 'messages#unread_count', as: :unread_messages_count

  get  'notifications',              to: 'notifications#index',         as: :notifications
  get  'notifications/unread_count', to: 'notifications#unread_count',  as: :notifications_unread_count
  patch 'notifications/mark_all_read', to: 'notifications#mark_all_read', as: :notifications_mark_all_read
  patch 'notifications/:id/mark_read', to: 'notifications#mark_read',     as: :notification_mark_read

  get 'sign_up' => 'users#new'
  get 'log_in'  => 'sessions#new'
  get 'log_out' => 'sessions#destroy'
end
