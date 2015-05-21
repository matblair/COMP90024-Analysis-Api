class Topics < ActiveRecord::Base

  # GET /topics/:topic
  def self.get_topic topic, demographic=nil, date_range=nil
    # Build start and end key
    startkey, endkey = build_keys topic, demographic, date_range

    # get sentiment summmary
    sentiment = (Couchdb.make_request 'tweets', 'topic', 'analysis', {'startkey'=>startkey, 'endkey'=>endkey})['rows'].first
  end

  def self.get_languages topic, demographic=nil, date_range=nil
    # Build start and end key
    startkey, endkey = build_keys topic, demographic, date_range

    # get language count
    language = Couchdb.make_request 'tweets', 'topic', 'language_count', {'startkey'=>startkey, 'endkey'=>endkey, 'group'=>true}
  end

  private
  def self.build_keys topic, demographic=nil, date_range=nil
    # Build start and end key
    startkey = []
    endkey = []
    common = [topic]
    # Add demographic markers
    if demographic
      if demographic.has_key? "political_leaning"
        common << demographic["political_leaning"]
      end
      if demographic.has_key? "language"
        if common.count < 2
          common << "aa"
        end
        common << demographic["language"]
      end
    end

    startkey = startkey.concat common
    endkey = endkey.concat common.map{|e| e.eql?("aa") ? {} : e }

    # Build start and end date
    if date_range && (date_range.has_key? "start_date") && (date_range.has_key? "end_date")

      # Find the start key
      start_date = parse_date date_range["start_date"]
      end_date = parse_date date_range["end_date"]
      # Pad both things
      if startkey.count < 3
        (3-startkey.count).times { startkey << "aa"}
      end
      if endkey.count < 3
        (3-endkey.count).times { endkey << {}}
      end

      startkey = startkey.concat start_date
      endkey = endkey.concat end_date
    end

    # Fill in endkey
    if endkey.count < 8
      (8-endkey.count).times { endkey << {}}
    end

    [startkey, endkey]
  end

  def self.get_extremes topic, demographic=nil, date_range=nil
    # Need to query for users
  end

  def self.parse_date date
    # Parse the date
    d = DateTime.parse(date)
    # Build json for that
    date_array = [d.year, d.month, d.day, d.hour, d.minute]
  end
end
