class Locations 


  def self.where date, demographic=nil, period= nil
    # Build the keys
    startkey, endkey = build_index_location_keys date, period, demographic 
    # Make the request
    r = (Couchdb.make_request 'tweets', 'location','sentiment_bydate', {'startkey'=>startkey, 'endkey'=>endkey,'group'=>true, 'group_level'=>9, 'limit'=>500})['rows']
  end

  #GET /locations/sentiment
  def self.get_sentiment lat, long, date_range = nil, period = nil, demographic = nil
    startkey, endkey = build_keys lat, long, date_range

    sentiment = (Couchdb.make_request 'tweets', 'location', 'sentiment', {'startkey'=>startkey, 'endkey'=>endkey})
  end

  #GET /locations/users
  #This is not working either
  def self.get_users
    location = (Couchdb.make_request 'tweets', 'location', 'loc_sentiment')
  end

  private
  def self.build_index_location_keys date, period, demo
    startkey = []
    endkey   = []

    # Work out times
    if period
      start_time, end_time = period.split(" - ")
      start_date = parse_date("#{date} #{start_time}")
      end_date = parse_date("#{date} #{end_time}")
    else
      start_date = parse_date("#{date} 0:00am")
      end_date = parse_date("#{date} 11:59pm")
    end

    # Add them to the keys
    startkey = startkey.concat start_date
    endkey = endkey.concat end_date

    ## Add ranges for lat lon (in that order)
    startkey = startkey.concat [-90,-180]
    endkey = endkey.concat [90,180]

    # Check if we have a demographic
    if demo
      # Check political leaning
      if demo.has_key? 'political_leaning'
        startkey << demo['political_leaning']
        endkey << demo['political_leaning']
      else
        startkey << {}
        endkey << {}
      end
      #Check languages
      if demo.has_key? 'language'
        startkey << demo['language']
      end
      endkey << {}
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
