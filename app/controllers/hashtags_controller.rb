class HashtagsController < ApplicationController
  include HashtagRepresentor
  include DemographicParser

  before_action :find_demo
  before_action :validate_date

  def show
    # Get the tag
    @tag = params[:hashtag]

    # Search couch for it
    stats = Hashtags.stats @tag, @demographic, @date_range
    if not (@demographic.has_key? 'language')
      puts @tag
      languages = Hashtags.languages(@tag)
    else
      languages = nil
    end

    # Return response
    if stats.count > 0
      render json: show_hashtag(@tag, stats, languages)
    else
      render json: {msg: "hashtag not found"}, status: :unprocessable_entity
    end
  end

  def topics
    # Make the request
    response = Hashtags.topics
    render json: response
  end


  def similar
    # Send the request to the graph api
    @tag = params[:hashtag]
    degree = params.has_key?('degree') ? (params['degree'].to_i) : 0
    frequency = params.has_key?('frequency') ? (params['frequency']) : false
    render json: Graph.similar_hashtags(@tag, degree, frequency)
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
