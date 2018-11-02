class GrandprixUpdater < Updater
  include HttpGet
  using StringToModel

  def parse(url)
    body = get_url(url)
    rows = body.xpath("//*[@class='GrandPrixListTable']/tr")
    events = []
    entries = []

    headers = rows[2].xpath('td')
    events = headers[0..5].map.with_index(1) do |header, i|
      { name: header.text.sub(/^[0-9]/, ''), number: i, done: true }
    end
    
    entries = rows[3..-1].map do |row|
      tds = row.xpath('td')
      points = []
      0.upto(5).each do |i|
        d = tds[3 + i].text
        if d == 'X'
          points[i] = 0
          events[i][:done] = false
        elsif d == ''
          points[i] = nil
        else
          points[i] = d.to_i
        end
      end
      { current_ranking: tds[0].text.to_i, skater_name: tds[1].text,
        skater_nation: tds[2].text, points: points, total: tds[9].text.to_i }
    end
    {
      events: events,
      entries: entries,
    }
  end

  def update(season, category)
    category_path = (category.name == 'ICE DANCE') ? 'gpsdance' : category.name.downcase
    url = "http://www.isuresults.com/events/gp#{season.start_date.year}/gps#{category_path}.htm"

    debug("update #{category.name} - #{url}")
    data = parse(url)

    ActiveRecord::Base.transaction do
      ## clean
      GrandprixEvent.where(season: season.to_s, category: category).map(&:destroy)

      data[:events].each do |event|
        GrandprixEvent.create!(season: season.to_s, category: category,
                               name: event[:name], number: event[:number], done: event[:done])
      end

      data[:entries].each do |entry|
        skater = entry[:skater_name].to_skater || raise("skater not found: #{entry[:skater_name]}")

        entry[:points].each.with_index(1) do |point, i|
          next if point.nil?

          event = GrandprixEvent.find_by!(season: season.to_s, category: category, number: i)
          GrandprixEntry.create!(skater: skater, ranking: entry[:current_ranking],
                                grandprix_event: event, point: point)
        end
      end
    end
  end
end
