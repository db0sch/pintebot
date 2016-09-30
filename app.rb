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
require './lib/foursquare'

# Include modules
include Nlp
include Geocode
include Foursquare

post '/gateway' do
  unless params[:user_id] == "USLACKBOT"

    # FIND OR CREATE THE USER
    unless user = User.find_by_slackid(params[:user_id])
      user = User.create!(slackid: params[:user_id], username: params[:user_name])
      p "new user with the id #{user.id}"
    else
      p "We found the user #{user.slackid}"
    end

    # CREATE A NEW QUERY
    query = Query.create!({
            user: user,
            text: params[:text],
            timestamp: params[:timestamp],
            slack_team: params[:team_id],
            slack_channel: params[:channel_id]
            })

    # ANALYSE THE TEXT (NLP - RECAST)
    nlp_result = recast_analyse(query.text)

    # Get coordinates from the NLP results (if location // otherwise, ask for an address)
    return respond_message "Sorry. I need an address." unless coordinates = get_coordinates(nlp_result)

    # UPDATE THE QUERY INSTANCE WITH NLP RESULT, AND COORDINATES
    query.update(nlp_result: nlp_result, drink: nlp_result['results']['intents'].first, geocode: coordinates)

    # CALL FOURSQUARE api
    return respond_message "Sorry, no cool bars around, bro!" unless result = get_nearest_place(coordinates)

    # CREATE THE REPLY HASH
    reply_args = {
      foursquare_result: result,
      name: result['name'],
      address: result['location']['address'],
      distance: result['location']['distance'],
      query: query,
    }

    # CREATE A REPLY INSTANCE
    reply = Reply.create({text: "You can have a drink at #{reply_args[:name]}, #{reply_args[:address]}. Distance: #{reply_args[:distance]}m"})

    # SEND THE RESPONSE MESSAGE
    respond_message reply.text

  end
end

def respond_message message
  content_type :json
  {:text => message}.to_json
end
