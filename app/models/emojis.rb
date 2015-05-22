class Emojis < ActiveRecord::Base

	def self.top_ten emoji_array
		return Hash[(emoji_array.sort_by {|hash| hash['value']['count']}).reverse.first(10).map {|key, value| [key, value]}]
	end

	def self.find_all emoji_array, emoji
		#emoji_array = emoji_array.select{|key| key[2] == emoji }
		emoji_array = emoji_array.select{|key, value| key[2] == emoji }
		return (emoji_array)
	end
end