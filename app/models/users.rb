class Users

	def self.user_info user_id
		# Get info for graph
		graph = Graph.find_connections user_id, 2
		user_name = graph['user']['screen_name']
		# Get info from couch
		response = Couchdb.make_request 'twitter_users', 'users','basic_info', {'key'=>user_name, 'group'=>true, 'group_leve'=>1}
		puts response
	end

end
