module Foursquare
  def get_nearest_place(coordinates = {})
    # At some point, we will query also the type of drink. Must be set up inside the nlp first.
    query_url = "https://api.foursquare.com/v2/venues/search?ll=#{coordinates['lat']},#{coordinates['lng']}&categoryId=56aa371ce4b08b9a8d57356c,4bf58dd8d48988d117941735,4bf58dd8d48988d11e941735,4bf58dd8d48988d11b941735,4bf58dd8d48988d11c941735,56aa371be4b08b9a8d57354d,4bf58dd8d48988d122941735,4bf58dd8d48988d123941735&radius=200&client_id=#{ENV['FOURSQUARE_CLIENT_ID']}&client_secret=#{ENV['FOURSQUARE_CLIENT_SECRET']}&v=20160918&intent=checkin"
    resp = HTTParty.get(query_url)
    result = JSON.parse(resp.body)['response']['venues'].max_by { |venue| venue['stats']['checkinsCount'] }
  end
end
