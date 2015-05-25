class Hashtags

  MAX_TRENDING = 10

  def self.trending demographic, date_range
    # Get all dates
    dates = build_dates date_range
    # For each date make the query
    start_date,end_date = dates.first.values

    # Find all the valid sub ranges
    tag_counts = {}
    dates.each do |date_pair|
      start_date,end_date = date_pair.values

      # Find the start and end key
      startkey, endkey = build_date_keys start_date, end_date, demographic
      response = (Couchdb.make_request 'tweets', 'hashtag', 'stats_bydate',
                  {'startkey'=>startkey, 'endkey'=>endkey, 'group'=>true, 'group_level'=>10})['rows']
      # Put them all in tag_counts
      if response
        response.each do |r|
          if tag_counts.has_key? r['key'].last
            existing = tag_counts[r['key'].last]
          else
            existing = {:count=>0, :subjectivity=>0, :polarity=>0}
          end
          existing[:count] += r['value']['count']
          existing[:subjectivity] += r['value']['subjectivity']*r['value']['count']
          existing[:polarity] += r['value']['polarity']*r['value']['count']
          tag_counts[r['key'].last] = existing
        end
      end
    end

    # Now pick the top ten
    # first get the counts
    top_ten_counts = tag_counts.reduce({}) {|h, (k,v)| (h[v[:count]] ||= []); h[v[:count]]<<[k,v]; h }.sort.last(10).reverse
    # Then fill up thing with values
    index = 0
    trending = {}
    top_ten_counts.each do |(count, values)|
      values.each do |tag, sentiment|
        if sentiment[:count] > 1
          sentiment[:subjectivity] = sentiment[:subjectivity]/sentiment[:count]
          sentiment[:polarity] = sentiment[:polarity]/sentiment[:count]
        end
        if index<= (MAX_TRENDING-1)
          trending[index]= {text: tag, subjectivity: sentiment[:subjectivity], count: count, polarity: sentiment[:polarity]}
          index += 1
        end

      end
    end
    trending
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

  def self.topics frequency=false
    topics = (Couchdb.make_request 'tweets', 'hashtag', 'stats', {'group'=>true, 'group_level'=>2})['rows']
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


  private

  def self.build_dates date_range
    puts date_range['end_date']
    if date_range && (date_range.has_key? "start_date") && (date_range.has_key? "end_date")
      DateMagic.build_date_keys date_range['start_date'], date_range['end_date']
    else
      DateMagic.build_date_keys (Date.today - 1.year).to_s, Date.today.to_s
    end
  end

  def self.build_date_keys startdate, enddate, demographic
    startkey = startdate
    endkey = enddate

    # Find demographic stuff
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
    else
      endkey << {}
    end

    [startkey,endkey]
  end

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

    # Add to the start and end keys
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
