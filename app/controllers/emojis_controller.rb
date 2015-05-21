class HashtagsController < ApplicationController
  include EmojiRepresentor
  include DemographicParser

  def top_ten 
  	# Make couch request for all emoji 
  	response = Couchdb.make_request 'tweets', 'emojis', 'general'
  	# Sort it
  	
  end

  def location

  end

end