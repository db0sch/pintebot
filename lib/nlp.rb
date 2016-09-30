# nlp stands for Natural Language Processing
# In this case, the processing engine is provided by Recast.ai

module Nlp
  def recast_analyse(message)
    result = HTTParty.post("https://api.recast.ai/v1/request",
      body: { text: message },
      headers: { 'Authorization' => "Token #{ENV['RECAST_DEV_ACCESS_TOKEN']}" }
    )

    return JSON.parse(result.body)
  end
end
