module LocationRepresentor
	extend ActiveSupport::Concern

	def index_json response
		{msg: "not implemented"}.to_json
	end

	def sentiment_json response
		{msg: "not implemented"}.to_json
	end


end
