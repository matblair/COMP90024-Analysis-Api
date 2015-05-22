module HashtagRepresentor
	extend ActiveSupport::Concern

	def show_hashtag tag, stats, langs
		stats = stats.first
		stats = stats['value']
		response = {
			text: tag,
			polarity: stats['polarity'],
			subjectivity: stats['subjectivity'],
			count: stats['count']
		}

		if langs && langs.count >=2
			response[:most_popular_languages]=langs.reduce({}){|h,(k,v)| (h[v] ||= []) << k;h}.max.last
			response[:least_popular_languages]=langs.reduce({}){|h,(k,v)| (h[v] ||= []) << k;h}.min.last
		elsif langs && langs.count >= 1
			response[:languages]=langs.keys
		end

		response
	end

	def show_trending response
		output = {:date => Date.today,
				  :time => Time.now,
				  :response => response}
		{msg: "not implemented"}.to_json
	end

end
