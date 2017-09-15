Rails.application.routes.draw do

  concern :api_base do
    resources :claims, only: [:create, :update, :show] do
      member do
        post 'change_to_complain'
        post 'add_file'
      end
    end

    resources :complains, only: [:update]
    resources :attentions, only: [:create, :update]
    resources :people, only: [:update]
  end

  namespace :v1 do
    concerns :api_base
  end

end
