class Graph
	
	NEO4J_IP = '144.6.227.66'
	NEO4J_PORT = 4500

	# Methods to retrieve information from the neo4j graph
	def self.similar_hashtags tag, degree=nil, frequency=nil
		request = "topics/#{tag}/similar?degree=#{degree ? degree : 0}&frequency=#{frequency ? frequency : false}"
		make_request request
	end

	# Methods to retrieve information from the neo4j graph
	def self.hashtag_info tag
		request = "topics/#{tag}"
		make_request request
	end

	# Find connections to a user
	def self.find_connections user

	end



    private
    def self.make_request request
    	# Build and return json response
	    uri = URI.encode("http://#{NEO4J_IP}:#{NEO4J_PORT}/api/#{request}")
	    req = Net::HTTP::Get.new(uri)
	    res = Net::HTTP.start(NEO4J_IP, NEO4J_PORT) { |http| http.request(req) }
	    if res.kind_of?(Net::HTTPSuccess)
	      return JSON.parse res.body
	    else
	      return :error
	    end
	end

end
