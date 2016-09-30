module Geocode
  def get_coordinates(data)
    if data['results']['sentences'].first['entities'].key?('location')
      coordinates = {}
      coordinates['lat'] = data['results']['sentences'].first['entities']['location'].first['lat']
      coordinates['lng'] = data['results']['sentences'].first['entities']['location'].first['lng']
      return coordinates
    end
  end
end
