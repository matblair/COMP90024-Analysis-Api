class InfoController < ApplicationController
  def index
  end

  def error
    render json: {msg: "Sorry, we don't know how to serve a request for #{params[:error]}"}, status: :not_found
  end

end
