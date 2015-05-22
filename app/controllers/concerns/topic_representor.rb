module TopicRepresentor
	extend ActiveSupport::Concern

	def show_json topic, sentiment, languages

		sentiment = sentiment['value']
		# Count languages
		langs = Hash.new(0)
		languages.each do |row|
			langs[row['key'].last] = row['value']
		end
		# # Remove undefined
		# langs.delete "und"
		
		response = {
			topic: topic,
			polarity: sentiment['polarity'],
			subjectivity: sentiment['subjectivity'],
			count: sentiment['count']
		}
		if langs && langs.count >=1
			puts langs
			response[:most_popular_languages]=langs.reduce({}){|h,(k,v)| (h[v] ||= []) << k;h}.max.last
			response[:least_popular_languages]=langs.reduce({}){|h,(k,v)| (h[v] ||= []) << k;h}.min.last
		end

		response
	end

	def location_json topic, vals
		# Map over everything and collect the values 
		response = {topic: topic}
		vals.map! do |val|
			entry = {subjectivity: val['subjectivity'],
					 polarity: val['polarity']}
			geo = {
			       lat: val['latitude'],
			       lon: val['longitude']
			      }
			entry['geo'] = geo
			entry
		end
		response['locations'] = vals
		response
	end

	def languages_json topic, vals
		# Map over everything and collect the values 
		response = {topic: topic}
		puts vals
		vals.map! do |val|
			entry = {language: val['key'].last,
					 count: val['value']}
		end
		response['languages'] = vals
		response
	end

	def extremes_json response
		{msg: "not implemented"}.to_json
	end


end
