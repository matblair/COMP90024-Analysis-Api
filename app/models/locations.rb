class Locations < ActiveRecord::Base
	#GET /locations
	#This doesn't work properly, don't know what input is needed for GET /locations
	def self.get_location date, demographic=nil, period= nil#lat, long, date_range = nil
		#startkey, endkey = build_keys lat, long, date_range
		sentiment = (Couchdb.make_request 'tweets', 'location', 'loc_sentiment')['rows'].first
	end

	#GET /locations/sentiment
	def self.get_sentiment lat, long, date_range = nil, period = nil, demographic = nil
		startkey, endkey = build_keys lat, long, date_range

		sentiment = (Couchdb.make_request 'tweets', 'location', 'sentiment', {'startkey'=>startkey, 'endkey'=>endkey})
	end

	#GET /locations/users
	#This is not working either
	def self.get_users user
		location = (Couchdb.make_request 'tweets', 'topic')
	end
	
	private
	def self.build_keys lat, long, date_range = nil
		startkey = []
		endkey   = []
		common   = [lat, long]

		#Add 'location' unrelated string
		startkey << "location"
		endkey   << "location"

	    startkey = startkey.concat common
    	endkey = endkey.concat common.map{|e| e.eql?("") ? {} : e }

		# Build start and end date
		if date_range && (date_range.has_key? "start_date") && (date_range.has_key? "end_date")

		  # Find the start key
		  start_date = parse_date date_range["start_date"]
		  end_date = parse_date date_range["end_date"]
		  # Pad both things
		  if startkey.count < 3
		    (3-startkey.count).times { startkey << ""}
		  end
		  if endkey.count < 3
		    (3-endkey.count).times { endkey << {}}
		  end

		  startkey = startkey.concat start_date
		  endkey = endkey.concat end_date
		end
	    [startkey, endkey]

	end 

	def self.parse_date date
    	# Parse the date
    	d = DateTime.parse(date)
    	# Build json for that
    	date_array = [d.year, d.month, d.day, d.hour, d.minute]
  	end
end
