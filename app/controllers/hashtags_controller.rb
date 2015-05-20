class HashtagsController < ApplicationController
  include HashtagRepresentor
  include DemographicParser

  before_action :find_demo
  before_action :validate_date

  def show
    # Get the tag
    tag = params[:hashtag]
    
    # Search couch for it
    couch_response = Hashtags.stats tag, @demographic, @date_range
    
    # Return response
    render json: couch_response
  end

  def similar
    # Send the request to the graph api

  end

  def trending
    # Find mood if it exists
    if params.has_key? 'mood'
      mood=params['mood']
    end

    # Make couch request
    couch_response = {1 => 'HELLO'}

    # Respond
    render json: show_trending(couch_response)
  end

  private

  # Find the topic we are referring to
  def find_topic
    @topic = params[:topic]
    if not (SUPPORTED_TOPICS.include? @topic)
      render json: {:error => "#{@topic} is not a supported topic."}, status: :unprocessable_entity
    end
  end

  # Find demographic information included
  def find_demo
    @demographic = extract_demographic params
  end

  #Validate all the params
  def validate_date
    if params.has_key?('start_date') &&  params.has_key?('end_date')
      @date_range = {"start_date" => params[:start_date], "end_date" => params[:end_date]}
    end
  end

end
