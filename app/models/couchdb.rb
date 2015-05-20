class Couchdb

  require 'net/http'
  require 'json'

  COUCH_PORT = 20010
  COUCH_IP = 'localhost'

  def self.make_request database, design_doc, view, params = nil

    # Make a request string to use
    if params
      # Build params key
      params_str = build_params params
      query = "#{database}/_design/#{design_doc}/_view/#{view}#{params_str}"
    else
      query = "#{database}/_design/#{design_doc}/_view/#{view}"
    end
    request_str = "http://#{COUCH_IP}:#{COUCH_PORT}/#{query}"

    # Build and return json response
    puts request_str
    uri = URI.encode(request_str)
    req = Net::HTTP::Get.new(uri)
    res = Net::HTTP.start(COUCH_IP, COUCH_PORT) { |http| http.request(req) }
    if res.kind_of?(Net::HTTPSuccess)
      return JSON.parse res.body
    else
      return :error
    end
  end


  private
  def self.build_params params
    params_str = '?'
    params.each_pair.with_index do |k,i|
      key,value = k
      params_str += "#{key}=#{value}"
      if i < (params.count - 1)
        params_str += '&'
      end
    end
    params_str
  end

end
