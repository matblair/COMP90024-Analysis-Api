class HashtagsController < ApplicationController
  include HashtagRepresentor
  include DemographicParser

  GRANULARITY_LEVELS = ['hourly', 'daily','weekly','monthly','yearly']

  before_action :find_demo
  before_action :validate_date
  before_action :validate_trend_params, only: [:trending]
  
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
    # Find limit if specified
    frequency = params.has_key?('frequency') ? params[:frequency] : nil

    # Make the request
    response = Hashtags.topics frequency
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
    case @granularity
    when 'hourly'
      @period = 1.hour
    when 'daily'
      @period = 1.day
    when 'weekly'
      @period = 7.day
    when 'monthly'
      @period = 30.day
    when 'yearly'
      @period = 365.day
    end

    #Initialize responses array
    responses = []

    # Go from start date to end date.
    puts @date_range  
    start = DateTime.parse @date_range['start_date']
    finish = DateTime.parse @date_range['end_date']
    i = 0
    # Collect all the things
    while start < finish do
      # Make a request
      enddate = start + @period
      response = (Hashtags.trending @demographic, {"start_date" => start.to_s, "end_date" => enddate.to_s})
      if response
        responses << { 
                        'start' => start.in_time_zone("Central Time (US & Canada)").to_formatted_s(:long_ordinal), 
                        'end' => enddate.in_time_zone("Central Time (US & Canada)").to_formatted_s(:long_ordinal), 
                        'trending' => response
                      }  
      else
        responses << {  'start' => start, 
                        'end' => enddate, 
                        'trending' => {}
                     }  
      end
      start = enddate
      i = i + 1
    end

    # Respond
    render json: show_trending(responses)
  end

  private
  
  def validate_trend_params
    
    # Find granularity if it exists
    if params.has_key?('granularity')
      @granularity = params['granularity']
    else
      @granularity = 'daily'
    end

    if not (GRANULARITY_LEVELS.include?(@granularity))
      render json: {:error => "#{@granularity} is not a valid granularity level."},
        status: :unprocessable_entity
    end
    

  end
  
  # Find the topic we are referring to
  def find_topic
    @topic = params[:topic]
    unless (SUPPORTED_TOPICS.include? @topic)
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
      @date_range = {"start_date" => DateMagic.sa_to_utc_string(params[:start_date]),
                     "end_date" => DateMagic.sa_to_utc_string(params[:end_date])}
    end
  end

end
