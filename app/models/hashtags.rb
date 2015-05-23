class Hashtags

  def self.trending demographic=nil, start_date, end_date
    #common = demographic['political_leaning']
    #Couchdb.make_request 'tweets','hashtag', 'stats', {'startkey'=>["unemployment","democrat","en",29,-99], 'endkey'=>["unemployment","democrat","en",30,-100,{},{},{},{},{}]}
    #startkey=
    response = (Couchdb.make_request 'tweets', 'hashtag', 'stats_bydate', {'group'=>true, 'group_level'=>10, 'limit' => 100})['rows']
    response = response.sort_by {|hash| hash['value']['count']}.reverse.first(10)
    response
    response.each_with_index do |hash, i|
      response[i] = {i.to_s => {
        'text' => hash['key'][9],
        'polarity' => hash['value']['polarity'],
        'subjectivity' => hash['value']['subjectivity']}
      }
      i = i+1
    end#, {'startkey'=>startkey, 'endkey'=>endkey}
  end

  def self.stats tag, demographic, date_range
  	# Find the start and end keys
  	startkey, endkey = build_keys tag, demographic, date_range
  	# Get the hashtags
  	tags = (Couchdb.make_request 'tweets', 'hashtag', 'stats',  {'startkey'=>startkey, 'endkey'=>endkey, 'group'=>true, 'group_level'=>1})['rows']
  end

  def self.languages tag
    language = (Couchdb.make_request 'tweets', 'hashtag', 'count', {'startkey'=>[tag], 'endkey'=>[tag,{}], 'group'=>true, 'group_level'=>2})['rows']
    languages = {}
    language.each{|e|languages[e['key'].last] = e['value']}
    languages
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
          common << ""
        end
        common << demographic["language"]
      end
    end

    startkey = startkey.concat common
    endkey = endkey.concat common.map{|e| e.eql?("") ? {} : e }

    # Build start and end date
    if date_range && (date_range.has_key? "start_date") && (date_range.has_key? "end_date")

      # Find the start key
      start_date = parse_date date_range["start_date"]
      end_date = parse_date date_range["end_date"]
      # Pad both things
      if startkey.count < 5
        (3-startkey.count).times { startkey << ""}
      end
      if endkey.count < 5
        (3-endkey.count).times { endkey << {}}
      end

      startkey = startkey.concat start_date
      endkey = endkey.concat end_date
    end

    # Fill in endkey
    if endkey.count < 10
      (10-endkey.count).times { endkey << {}}
    end

    [startkey, endkey]
  end


end
