class Locations 


  def self.where date, demographic=nil, period= nil
    # Build the keys
    startkey, endkey = build_index_location_keys date, period, demographic 
    # Make the request
    r = (Couchdb.make_request 'tweets', 'location','sentiment_bydate', {'startkey'=>startkey, 'endkey'=>endkey,'group'=>true, 'group_level'=>9, 'limit'=>500})['rows']
  end

  #GET /locations/sentiment
  def self.sentiment_in start_loc, end_loc, start_date, end_date, period=nil, demographic=nil, limit=nil
    startkey, endkey = build_sentiment_location_keys start_loc, end_loc, start_date, end_date, period, demographic
    if limit
      response = (Couchdb.make_request 'tweets', 'location', 'sentiment_bydate', {'startkey'=>startkey, 'endkey'=>endkey, 'reduce'=>false, 'limit'=> limit})
    else
      response = (Couchdb.make_request 'tweets', 'location', 'sentiment_bydate', {'startkey'=>startkey, 'endkey'=>endkey, 'reduce'=>false})
    end

    total = response['total_rows']
    sentiment = response['rows']
    # Now we need to process sentiment
    polarities = Hash.new(0)
    subjectivities = Hash.new(0)
    # Loop through
    sentiment.each do |elem|
      vals = elem['value']
      polarities[(vals['polarity']).round(1)] += 1
      subjectivities[(vals['subjectivity']).round(1)] +=1
    end
    {polarities: polarities, subjectivities: subjectivities, points: sentiment.count, total: total}

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

    def self.build_sentiment_location_keys start_loc, end_loc, start_date, end_date, period, demo
    # Pattern is
    # [lat, lon, leaning, lang, year, day, month, hour, minute]
    startkey = []
    endkey   = []

    # Work out times
    if period
      start_time, end_time = period.split(" - ")
      start_date = parse_date("#{start_date} #{start_time}")
      end_date = parse_date("#{end_date} #{end_time}")
    else
      start_date = parse_date("#{start_date} 0:00am")
      end_date = parse_date("#{end_date} 11:59pm")
    end

    # Add them to the keys
    startkey = startkey.concat (start_date+start_loc)
    endkey = endkey.concat (end_date+end_loc)

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
