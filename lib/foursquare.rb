module Foursquare
  def get_nearest_place(coordinates = {})
    # At some point, we will query also the type of drink. Must be set up inside the nlp first.
    query_url = "https://api.foursquare.com/v2/venues/search?ll=#{coordinates['lat']},#{coordinates['lng']}&categoryId=56aa371ce4b08b9a8d57356c&radius=500&client_id=#{ENV['FOURSQUARE_CLIENT_ID']}&client_secret=#{ENV['FOURSQUARE_CLIENT_SECRET']}&v=20160918&intent=checkin"
    p query_url
    resp = HTTParty.get(query_url)
    p resp
    result = JSON.parse(resp.body)['response']['venues'].first
  end
end
