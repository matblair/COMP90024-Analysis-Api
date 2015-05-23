class Hashtags

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

  def self.topics frequency=false
    topics = (Couchdb.make_request 'tweets', 'hashtag', 'stats', {'group'=>true, 'group_level'=>2, 'limit'=>5000})['rows']
    # Go Through and Build Hash
    temp = {}
    topics.each do |topic|
      tag = topic['key'].first
      demo = topic['key'].last
      count = topic['value']['count']
      temp[demo] ||= {}
      temp[demo][tag]=count
    end

    # Create a response
    response = {"none"=>{},"democrat"=>{},"republican"=>{}}
    # Find the top ten for each
    temp.each_pair do |key,value|
      top = value.reduce({}){|h,(k,v)| (h[v] ||= []) << k;h}.sort.last(10).reverse
      # Pick from these until we have the top amount
      top_ten = {}
      top.each do |elem|
        count, tags = elem
        tags.each do |t|
          top_ten[t]=count
        end
        response["#{key}"] = top_ten
      end
    end
    # Change to array if not frequency
    if !frequency
      response.each {|k,vals| response[k]=vals.keys}
    end
    response
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
