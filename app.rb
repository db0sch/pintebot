require 'sinatra'
require 'dotenv'
Dotenv.load
require 'sinatra/activerecord'
require './config/environments' #database configuration
require 'httparty'
require 'json'
require 'geocoder'
require './models/user'
require './models/query'
require './models/reply'
require './lib/nlp'
require './lib/geocode'

# Include modules
include Nlp
include Geocode

post '/gateway' do
  unless params[:user_id] == "USLACKBOT"

    # FIND OR CREATE THE USER
    p params
    unless user = User.find_by_slackid(params[:user_id])
      user = User.create!(slackid: params[:user_id], username: params[:user_name])
    else
      p "We found the user #{user.slackid}"
    end
    p user

    # CREATE A NEW QUERY
    query = Query.create!({
            user: user,
            text: params[:text],
            timestamp: params[:timestamp],
            slack_team: params[:team_id],
            slack_channel: params[:channel_id]
            })
    p query

    # ANALYSE THE TEXT (NLP - RECAST)
    nlp_result = recast_analyse(query.text)
    p nlp_result

    # Get coordinates from the NLP results (if location // otherwise, ask for an address)
    return respond_message "Sorry. I need an address." unless coordinates = get_coordinates(nlp_result)

    # UPDATE THE QUERY INSTANCE WITH NLP RESULT, AND COORDINATES
    query.update(nlp_result: nlp_result, drink: nlp_result['results']['intents'].first, geocode: coordinates)

    # nlp_result = recast_api(message)

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
