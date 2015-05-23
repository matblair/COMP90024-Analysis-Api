class LocationsController < ApplicationController
	include LocationRepresentor
	include DemographicParser

	before_action :validate_sentiment_params, only: [:sentiment]
	# Find demographic if it exists
	before_action :find_demo


	def sentiment
		# Find the location
		start_loc = [params['start_lat'],params['start_lon']]
		end_loc = [params['end_lat'],params['end_lon']]

		# Find required date
		if params.has_key?('start_date') && params.has_key?('end_date')
			# Find the period	
			start_date = params['start_date']
			end_date = params['end_date']
		else
			start_date = 100.years.ago
			end_date = Date.today
		end
		# Find limit if specified
		limit = params.has_key?('limit') ? params[:limit] : nil

		# Find the period if it's specified
		period = params.has_key?('period') ? params[:period] : nil

		# Make couch request for sentiment
		analysis = Locations.sentiment_in start_loc, end_loc, start_date, end_date, period, @demographic, limit

		# Render json
		render json: sentiment_json(start_loc, end_loc, start_date, end_date, analysis, period)
	end

	def index
		# Find required date
		if params.has_key? 'date'
			# Find the period	
			period = params.has_key?('period') ? params[:period] : nil
			date = params[:date]
		else
			date = Date.yesterday.to_s
			period = nil
		end

		# Find limit if specified
		limit = params.has_key?('limit') ? params[:limit] : nil

		# Make couch request
		couch_response = Locations.where date, @demographic, period
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

	private
	def find_demo
		@demographic = extract_demographic params
	end


end

