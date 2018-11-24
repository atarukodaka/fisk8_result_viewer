require 'rails_helper'

RSpec.describe YoutubeHelper do
  context 'youtube' do
    include YoutubeHelper

    before do
      url = 'https://www.googleapis.com/youtube/v3/search?key=&order=relevance&part=snippet&q='

      WebMock.enable!
      WebMock.stub_request(:get, url).to_return(
        body: File.read((Rails.root.join('spec/fixtures/webmock', 'youtube-api.json')).to_s),
        status: 200,
        headers: { 'content-type': 'application/json' }
      )
    end
    it {
      item = parse_youtube('', api_key: nil)
      expect(item[:id]).to eq('23EfsN7vEOA')
      expect(item[:title]).to eq("Yuzuru Hanyu (JPN) - Gold Medal | Men's Figure Skating | Free Programme | PyeongChang 2018")  ## rubocop:disable Metrics/LineLength
      expect(item[:published_at]).to eq(Time.utc(2018, 3, 9, 17, 0, 0).in_time_zone('UTC'))
    }
  end
end
