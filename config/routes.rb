Rails.application.routes.draw do
  # Informaton page with usage data
  get 'info/index'
  root 'info#index'

  # Routes for users
  get 'users' => 'users#index'
  get 'users/:user_id' => 'users#show'
  get 'users/:user_id/connections' => 'users#connections'
  get 'users/demographics' => 'users#demographics'

  # Routes for hashtags
  get 'hashtags/trending' => 'hashtags#trending'
  get 'hashtags/stats/:hashtag' => 'hashtags#show'
  get 'hashtags/topics' => 'hashtags#topics'
  get 'hashtags/:hashtag/similar' => 'hashtags#similarå'

  # Routes for locations
  get 'locations' => 'locations#index'
  get 'locations/sentiment' => 'locations#sentiment'

  # Routes for topics
  get 'topics/:topic' => 'topics#show'
  get 'topics/:topic/trend' => 'topics#trend'
  get 'topics/:topic/extremes' => 'topics#extremes'
  get 'topics/:topic/locations' => 'topics#locations'

  # Routes for emojis
  get '/emoji/general' => 'emojis#top_ten'
  get '/emoji/:emoji_code/locations' => 'emojis#location'

end
