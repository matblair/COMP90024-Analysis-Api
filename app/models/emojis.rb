class Emojis < ActiveRecord::Base

  LOCATION_LAT_POS = 0
  LOCATION_LON_POS = 1
  LOCATION_EMOJI_POS = 2

  def self.top_ten
    # Make couch request for all emoji
    response = (Couchdb.make_request 'tweets', 'emojis', 'general', {'group'=>true, 'group_level'=>1})['rows']
    top_ten = response.sort_by {|hash| hash['value']['count']}.reverse.first(10)
    return top_ten
  end

  def self.all_locations emoji
    # Make couch request for all emoji
    response = (Couchdb.make_request 'tweets', 'emojis', 'general_byloc', {'group'=>true, 'group_level'=>3})['rows']
    locations = []
    response.each do |elem|
    	keys = elem["key"]
    	if keys[LOCATION_EMOJI_POS].to_s == Emoji.find_by_alias(emoji).raw
    		locations << {lat: keys[LOCATION_LAT_POS], lon: keys[LOCATION_LON_POS]}
    	end
    end
    return {locations: locations, emoji_name: emoji, emoji: Emoji.find_by_alias(emoji).raw, count: locations.count}
  end
end
