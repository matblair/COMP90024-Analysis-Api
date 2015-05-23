module TopicRepresentor
  extend ActiveSupport::Concern

  def show_json topic, sentiment, languages
    # langs.delete "und"
    response = {
      topic: topic,
      polarity: sentiment[:polarity],
      subjectivity: sentiment[:subjectivity],
      count: sentiment[:count]
    }
    if languages && languages.count >=1
      # Count languages
      langs = Hash.new(0)
      languages.each do |row|
        langs[row['key'].last] = row['value']
      end
      response[:most_popular_languages]=langs.reduce({}){|h,(k,v)| (h[v] ||= []) << k;h}.max.last
      response[:least_popular_languages]=langs.reduce({}){|h,(k,v)| (h[v] ||= []) << k;h}.min.last
    end

    response
  end

  def location_json topic, vals
    # Map over everything and collect the values
    response = {topic: topic}
    vals.map! do |val|
      entry = {subjectivity: val['subjectivity'],
               polarity: val['polarity']}
      geo = {
        lat: val['latitude'],
        lon: val['longitude']
      }
      entry['geo'] = geo
      entry
    end
    response['locations'] = vals
    response
  end

  def languages_json topic, vals
    # Map over everything and collect the values
    response = {topic: topic}
    vals.map! do |val|
      entry = {language: val['key'].last,
               count: val['value']}
    end
    response['languages'] = vals
    response
  end

  def extremes_json response
    {msg: "not implemented"}.to_json
  end


end
