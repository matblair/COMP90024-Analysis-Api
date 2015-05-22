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

	def sentiment_json response
		{msg: "not implemented"}.to_json
	end


end
