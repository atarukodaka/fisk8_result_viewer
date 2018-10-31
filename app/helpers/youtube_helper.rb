module YoutubeHelper
  def parse_youtube(query, api_key:)
    begin
      base_url = 'https://www.googleapis.com/youtube/v3/search'
      url = [base_url, '?', { part: :snippet, q: query, order: :relevance, key: api_key }.to_query].join
      response = open(url).read  ## rubocop:disable Security/Open:
    rescue OpenURI::HTTPError
      return nil
    end
    json = JSON.parse(response)
    return nil unless (item = json['items'].first)

    {
      id: item['id']['videoId'],
      title: item['snippet']['title'],
      published_at: item['snippet']['publishedAt'].in_time_zone('UTC'),
    }
  end
end
