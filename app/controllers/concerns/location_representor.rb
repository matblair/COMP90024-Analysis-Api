module LocationRepresentor
	extend ActiveSupport::Concern

	def index_json response, date, period=nil
		json = {date: date}
		if period then json['period']=period end
		locs = []
		# Loop through locaitons and do stuff
		response.each do |elem|
			puts elem
			keys = elem['key']
			vals = elem['value']
			sentiment = {
				polarity: vals['polarity'],
				subjectivity: vals['subjectivity']
			}
			geo_points = {
				lat: keys[5],
				lon: keys[6]
			}
			locs << {point: geo_points, sentiment: sentiment}
		end
		json['locations'] = locs
		json
	end

	def sentiment_json start_loc, end_loc, start_date, end_date, analysis, period=nil
		response = {
			start_lat:  start_loc[0],
			start_lon:  start_loc[1],
			end_lat:    start_loc[0],
		    end_lon:    start_loc[1],
		    start_date: start_date,
			end_date: 	end_date,
			sentiment:  analysis
		}
		if period
			response[:period]=period
		end
		response
	end


end
