Rails.application.routes.draw do
  get 'search', to: 'index#search'
  root 'index#search'
end
