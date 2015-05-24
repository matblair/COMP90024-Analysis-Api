module EmojiRepresentor
	extend ActiveSupport::Concern

	def top_ten_response top_ten
		response = {}
		top_ten.each_with_index do |elem, index|
			# Extract the values
			vals = elem["value"]
			# Build the elem hash
			elem_hash = {
				emoji: elem["key"].first,
				emoji_name: (Emoji.find_by_unicode(elem["key"].first) ? Emoji.find_by_unicode(elem["key"].first).name : nil),
				count: vals["count"],
				avg_subjectivity: vals["subjectivity"],
				avg_polarity: vals["polarity"]
			}
			# Add the elem hash no to response
			response[index] = elem_hash
		end
		response.to_json
	end


end
