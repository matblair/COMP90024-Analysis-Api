class TopicsController < ApplicationController
  include DemographicParser
  include TopicRepresentor


  # Supported Topics and levels
  SUPPORTED_TOPICS = ['gun_control','mention_immigration','unemployment']
  GRANULARITY_LEVELS = ['daily','weekly','monthly','yearly', 'hourly']

  # Before all find the topic params
  before_action :find_topic
  # Find the demographic if it exists
  before_action :find_demo, only: [:show,:trend, :languages]
  # Validate params
  before_action :validate_date
  before_action :validate_trend_params, only: [:trend]

  def show
    # Get couch request
    sentiment = Topics.get_topic @topic, @demographic, @date_range
    # Get languages unless searching for a particular one
    if not (@demographic.has_key? 'language')
      languages = Topics.get_languages @topic
    else
      languages = nil
    end
    
    # Render json
    render json: show_json(@topic, sentiment, languages)
  end

  def locations
    # Get response
    limit = params.has_key?('limit') ? params['limit'] : 2000
    response = Topics.get_locations @topic
    render json: location_json(@topic, response)
  end

  def languages 
    # # Get couch request
    languages = Topics.get_languages @topic, @demographic, @date_range
    render json: languages_json(@topic, languages).to_json
  end


  def trend
    # Work out day split
    case @granularity
    when 'daily'
      @period = 1.day
    when 'weekly'
      @period = 1.week
    when 'monthly'
      @period = 1.month
    when 'yearly'
      @period = 1.year
    when 'hourly'
      @period = 1.hour
    end

    # Responses
    responses = []

    # Go from start date to end date.
    start = DateTime.parse @date_range['start_date']
    finish = DateTime.parse @date_range['end_date']
    
    # Collect all the things
    while start < finish
      # Make a request
      enddate = start + @period
      response = (Topics.get_topic @topic, @demographic,{"start_date" => start.to_s, "end_date" => enddate.to_s})
      if response
        responses << {'start' => start.in_time_zone("Central Time (US & Canada)").to_formatted_s(:long_ordinal), 
                      'end' => enddate.in_time_zone("Central Time (US & Canada)").to_formatted_s(:long_ordinal), 
                      'count' => response[:count],
                      'subjectivity' => response[:subjectivity], 
                      'polarity' => response[:polarity]}
      else
        responses << {'start' => start, 'end' => enddate, 'count' => 0,
                      'subjectivity' => nil, 'polarity' => nil}
      end
      start = enddate
    end

    # Work out trend from start and end
    polarities = responses.map {|e| e['polarity']}
    polarities.delete nil

    if polarities && (polarities.first > polarities.last)
      if (polarities.first - polarities.last).abs > 0.5
        trend = 'decreasing'
      else
        trend = 'stable'
      end
    elsif polarities
      if (polarities.first - polarities.last).abs > 0.5
        trend = 'increasing'
      else
        trend = 'stable'
      end
    end

    # Render json
    render json: {topic: @topic, trend: trend, time_periods: responses}

  end

  def extremes
    # Get couch request
    couch_response = '@date_range'
    # Render json
    render json: extremes_json(couch_response)
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
      @date_range = {"start_date" => DateMagic.sa_to_utc_string(params[:start_date]),
                     "end_date" => DateMagic.sa_to_utc_string(params[:end_date])}
    end
  end

  def validate_trend_params
    params.require(:granularity)
    @granularity = params['granularity']
    if not (GRANULARITY_LEVELS.include?(@granularity))
      render json: {:error => "#{@granularity} is not a valid granularity level."},
        status: :unprocessable_entity
    end
  end

end
