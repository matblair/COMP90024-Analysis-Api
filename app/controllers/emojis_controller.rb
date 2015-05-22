class EmojisController < ApplicationController
  include EmojiRepresentor
  include DemographicParser

  # Find 
  before_action :validate_emoji_code, only: [:location]

  def top_ten 
    # Sort it and return  hash
    top_ten_hash = Emojis.top_ten
    render json: top_ten_response(top_ten_hash)
  end

  def location
    # Return the selected emoji's location based on :emoji_code param
    response = Emojis.all_locations @emoji
    render json: response.to_json
  end

  private
  def validate_emoji_code
    @emoji = params[:emoji_code]
  end

end