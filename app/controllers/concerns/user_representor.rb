module UserRepresentor
	extend ActiveSupport::Concern

	def user_show_json couch, neo
		{msg: "not implemented"}.to_json
	end

	def connections_json user, connections, demos
		{msg: "not implemented"}.to_json
	end

	def user_index_json response
		{msg: "not implemented"}.to_json
	end

end