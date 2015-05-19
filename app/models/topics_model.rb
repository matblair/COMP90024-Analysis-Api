class TopicsModel < ActiveRecord::Base

    # GET /topics/:topic
    def get_topic argument

        # get sentiment summmary
        url = URI.parse("http://144.6.227.66:5984/tweets/_design/topic/_view/analysis?startkey=["gun_control"]&endkey=["gun_control",{},{},{},{},{},{},{}]")
        req = Net::HTTP::Get.new(url.to_s)
        sent_res = Net::HTTP.start(url.host, url.port) {|http|
            http.request(req)
        }

        # get language count
        url = URI.parse("http://144.6.227.66:5984/tweets/_design/topic/_view/language_count?startkey=["gun_control"]&endkey=["gun_control",{}]&group=true")
        req = Net::HTTP::Get.new(url.to_s)
        lang_res = Net::HTTP.start(url.host, url.port) {|http|
            http.request(req)
        }

        

    end    

    def 
end
