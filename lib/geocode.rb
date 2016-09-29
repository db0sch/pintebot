module Geocoder
  def get_coordinates
    if nlp_result['results']['sentences'].first['entities'].key?('location')
      coordinates = {}
      coordinates['lat'] = nlp_result['results']['sentences'].first['entities']['location'].first['lat']
      coordinates['lng'] = nlp_result['results']['sentences'].first['entities']['location'].first['lng']
      return coordinates
    end
  end
end
