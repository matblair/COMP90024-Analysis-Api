class LocationsController < ApplicationController
	include LocationRepresentor
	include DemographicParser

	before_action :validate_sentiment_params, only: [:sentiment]
	# Find demographic if it exists
	before_action :find_demo


	def sentiment
		# Find the location
		location = params[:location]

		# Find the range if included and the period if included
		period = params.has_key?('period') ? params['period'] : nil
		range = params.has_key?('range') ? params['range'] : nil
		# Verify range has start and end date or emit it
		if range && !(range.has_key?('start_date') && range.has_key?('end_date'))
			range = nil
		end

		# Make couch request for sentiment
		couch_response = Locations.where 

		# Render json
		render json: couch_response
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
		params.require(:location)
	end

	private
	def find_demo
		@demographic = extract_demographic params
	end



end
