class EmojisController < ApplicationController
  include EmojiRepresentor
  include DemographicParser

  # Find 
  before_action :validate_emoji_code, only: [:location]
  def top_ten 
  	# Make couch request for all emoji
  	response = (Couchdb.make_request 'tweets', 'emojis', 'general', {'group'=>true, 'group_level'=>1})['rows']
    # Sort it and return  hash
    response = Emojis.top_ten response
    render json: response
  end

  def location
    # Make couch request for all emoji
    response = (Couchdb.make_request 'tweets', 'emojis', 'general_byloc', {'group'=>true, 'group_level'=>9})['rows']
    # Return the selected emoji's location based on :emoji_code param
    response = Emojis.find_all response, @emoji['emoji_code'].to_s
    render json: response
  end

  private
  def validate_emoji_code
    if params.has_key?('emoji_code')
      @emoji = {"emoji_code" => params[:emoji_code]}
    end
  end

end