class LocationsController < ApplicationController
  include LocationRepresentor
  include DemographicParser

  before_action :validate_sentiment_params, only: [:sentiment]
  # Find demographic if it exists
  before_action :find_demo
  before_action :validate_date

  def sentiment
    # Find the location
    start_loc = [params['start_lat'],params['start_lon']]
    end_loc = [params['end_lat'],params['end_lon']]

    # Find required date
    if ! @date_range
      # Find the period
      @date_range = {"start_date" =>100.years.ago.to_s,
                    "end_date" => Date.today.to_s }
    end
    # Find limit if specified
    limit = params.has_key?('limit') ? params[:limit] : nil

    # Find the period if it's specified
    period = params.has_key?('period') ? params[:period] : nil

    # Make couch request for sentiment
    analysis = Locations.sentiment_in start_loc, end_loc, @date_range['start_date'], @date_range['end_date'], period, @demographic, limit

    # Render json
    render json: sentiment_json(start_loc, end_loc, @date_range['start_date'], @date_range['end_date'], analysis, period)
  end

  def index
    # Find required date
    if params.has_key? 'date'
      # Find the period
      period = params.has_key?('period') ? params[:period] : nil
      # Change the period to utc for seach
      if period
        times = period.split(" - ")
        start_time = DateMagic.utc_time_from_str(times.first)
        end_time = DateMagic.utc_time_from_str(times.last)
        correct_period = "#{start_time.to_formatted_s(:time)} - #{end_time.to_formatted_s(:time)}"
        puts correct_period
      else
      	correct_period=nil
      end
      date = DateMagic.sa_to_utc_string(params[:date])
    else
      date = Date.yesterday.to_s
      period = nil
    end

    # Find limit if specified
    limit = params.has_key?('limit') ? params[:limit] : nil

    # Make couch request
    couch_response = Locations.where date, @demographic, correct_period
    # Render json
    render json: index_json(couch_response, date, period)
  end

  def users
    location_range = Locations.get_users
  end

  private

  # Find required sentiment params
  def validate_sentiment_params
    params.require(:start_lat)
    params.require(:start_lon)
  end

  #Validate all the params
  def validate_date
    if params.has_key?('start_date') &&  params.has_key?('end_date')
      @date_range = {"start_date" => DateMagic.sa_to_utc_string(params[:start_date]),
                     "end_date" => DateMagic.sa_to_utc_string(params[:end_date])}
    end
  end

  private
  def find_demo
    @demographic = extract_demographic params
  end


end
