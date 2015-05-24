class Topics

  # GET /topics/:topic
  def self.get_topic topic, demographic=nil, date_range=nil

    # Get all dates
    dates = build_dates date_range

    # Hold all the results
    sentiment =  {count: 0, subjectivity: 0, polarity: 0}

    dates.each do |date|
      start_date = date[:start_date]
      end_date = date[:end_date]
      # Build start and end keys
      if demographic.has_key?('political_leaning')
        startkey, endkey = build_sentiment_keys topic, start_date, end_date, demographic
        response = (Couchdb.make_request 'tweets', 'topic', 'analysis', {'startkey'=>startkey, 'endkey'=>endkey})['rows']
      elsif demographic.has_key?('language')
        startkey, endkey = build_lang_keys topic, start_date, end_date, demographic
        response = (Couchdb.make_request 'tweets', 'topic', 'analysis_lang_only', {'startkey'=>startkey, 'endkey'=>endkey})['rows']
      else
        startkey, endkey = build_date_keys topic, start_date, end_date, demographic
        response = (Couchdb.make_request 'tweets', 'topic', 'analysis_bydate', {'startkey'=>startkey, 'endkey'=>endkey})['rows']
      end
      if response && (not response.empty?)
        response = response.first
        sentiment[:count] += response['value']['count']
        sentiment[:subjectivity] += response['value']['subjectivity']*response['value']['count']
        sentiment[:polarity] += response['value']['polarity']*response['value']['count']
      end
    end
    if sentiment[:count] > 1
      sentiment[:subjectivity] = sentiment[:subjectivity]/sentiment[:count]
      sentiment[:polarity] = sentiment[:polarity]/sentiment[:count]
    end
    return sentiment
  end

  def self.get_languages topic
    # get language count
    language = (Couchdb.make_request 'tweets', 'topic', 'language_count', {'startkey'=>[topic], 'endkey'=>[topic,{}], 'group'=>true})['rows']
  end

  def self.get_locations topic, limit=nil
  	if limit
    	locations = (Couchdb.make_request 'tweets','topic','location', {'startkey'=>[topic], 'endkey'=>[topic,{}], 'reduce'=>false, 'limit'=>limit})['rows']
    else
    	locations = (Couchdb.make_request 'tweets','topic','location', {'startkey'=>[topic], 'endkey'=>[topic,{}], 'reduce'=>false})['rows']
    end
    # Collection the values
    locations.map{|e| e['value']}
  end

  private
  def self.build_dates date_range
    if date_range && (date_range.has_key? "start_date") && (date_range.has_key? "end_date")
      DateMagic.build_date_keys date_range['start_date'], date_range['end_date']
    else
      DateMagic.build_date_keys (Date.today - 1.year).to_s, Date.today.to_s
    end
  end

  private
  def self.build_sentiment_keys topic, start_date, end_date, demographic=nil
    # Build start and end key
    startkey = []
    endkey = []
    common = [topic]
    # Add demographic markers
    if demographic
      if demographic.has_key? "political_leaning"
        common << demographic["political_leaning"]
      else
        common << "a"
      end

      if demographic.has_key? "language"
        common << demographic["language"]
      else
        common << "a"
      end
    end

    startkey = startkey.concat common
    endkey = endkey.concat common.map{|e| e.eql?("a") ? {} : e }

    startkey = startkey.concat start_date
    endkey = endkey.concat end_date


    # Fill in endkey
    if endkey.count < 8
      (8-endkey.count).times { endkey << {}}
    end

    [startkey, endkey]
  end

  def self.build_date_keys topic, start_date, end_date, demographic=nil
    # Build start and end key
    startkey = [topic]
    endkey = [topic]

    startkey = startkey.concat start_date
    endkey = endkey.concat end_date

    # Add demographic markers
    if demographic
      if demographic.has_key? "language"
        startkey << demographic["language"]
        endkey << demographic["language"]
      else
        startkey << "a"
        endkey << {}
      end
      if demographic.has_key? "political_leaning"
        startkey << demographic["political_leaning"]
        endkey << demographic["political_leaning"]
      else
        endkey << {}
      end
    end

    [startkey, endkey]
  end


  def self.build_lang_keys topic, start_date, end_date, demographic=nil
    # Build start and end key
    startkey = [topic]
    endkey = [topic]

    # Add demographic markers
    if demographic
      if demographic.has_key? "language"
        startkey << demographic["language"]
        endkey << demographic["language"]
      else
        startkey << "a"
        endkey << {}
      end
    end

    startkey = startkey.concat start_date
    endkey = endkey.concat end_date

    # Add demographic markers
        if demographic
      if demographic.has_key? "political_leaning"
        startkey << demographic["political_leaning"]
        endkey << demographic["political_leaning"]
      else
        endkey << {}
      end
    end


    [startkey, endkey]
  end

  # def self.get_extremes topic, demographic=nil, date_range=nil
  #   # Need to query for users
  # end

end
