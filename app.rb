require 'sinatra'
require 'httparty'
require 'json'
require 'dotenv'
require 'geocoder'
Dotenv.load

post '/gateway' do
  message = params[:text]
  nlp_result = recast_api(message)
  p nlp_result

  if nlp_result['results']['sentences'].first['entities'].key?('location')
    address = nlp_result['results']['sentences'].first['entities']['location']
    # geocode = Geocoder.search(address)
    # coordinates = geocode.first.data["geometry"]["location"]
    coordinates = {}
    coordinates['lat'] = nlp_result['results']['sentences'].first['entities']['location'].first['lat']
    coordinates['lng'] = nlp_result['results']['sentences'].first['entities']['location'].first['lng']
    p coordinates
    resp = foursquare_api(coordinates)
    p resp
    unless resp['response']['venues'].empty?
      bar_name = resp['response']['venues'].first['name']
      p bar_name
      bar_address = resp['response']['venues'].first['location']['address']
      p bar_address
      bar_distance = resp['response']['venues'].first['location']['distance']
      respond_message "You can have a drink at #{bar_name}, #{bar_address}. Distance: #{bar_distance}m"
    end
  else
    return respond_message "Sorry. I need an address."
  end
end

def respond_message message
  content_type :json
  {:text => message}.to_json
end

def recast_api(message)
  result = HTTParty.post("https://api.recast.ai/v1/request",
    body: { text: message },
    headers: { 'Authorization' => "Token #{ENV['RECAST_DEV_ACCESS_TOKEN']}" }
  )

  return JSON.parse(result.body)
end

def foursquare_api(coordinates = {})
  query_url = "https://api.foursquare.com/v2/venues/search?ll=#{coordinates['lat']},#{coordinates['lng']}&radius=500&client_id=#{ENV['FOURSQUARE_CLIENT_ID']}&client_secret=#{ENV['FOURSQUARE_CLIENT_SECRET']}&v=20160918&query=beer&intent=checkin"
  resp = HTTParty.get(query_url)
  p JSON.parse resp.body
  resp = JSON.parse resp.body
end

# https://api.foursquare.com/v2/venues/search?near=16 villa gaudelet paris&client_id=VW12BWAGIIC5XXLJUXRYAV345JYG1NLGUD0GMKHIXDDVXVHX&client_secret=ZJ02JEVQ1XJEXKF1NTP1J1QZ4IRPSVQ3IC53WAOGV4WXNNFH&query=beer
