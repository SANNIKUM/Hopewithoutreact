Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  mount GraphiQL::Rails::Engine, at: "/web_api/graphql", graphql_path: "/web_api/graphql"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'application#index'

  get 'download/:assignment_name', to: 'downloads#download'

  get '/loaderio-8b5db859acd181a3d6d4eef46ff14eff/', :to => redirect('/loader.html')

  namespace :web_api do
    post 'graphql', to: 'graphql#create'
    post 'download', to: 'downloads#download'
    post 'getSurveySubmittedList', to: 'downloads#getSurveySubmittedList'
  end

  namespace :api do
    namespace :v1 do
      get 'test', to: 'test#test'
      post 'test', to: 'test#post_test'



      post 'users', to: 'users#create'
      post 'submitted_forms', to: 'submitted_forms#create'
      post 'soft_delete', to: 'submitted_forms#soft_delete'
    end
  end
end
