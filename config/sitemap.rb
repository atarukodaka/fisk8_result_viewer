# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = Settings.about.site_url

SitemapGenerator::Sitemap.create do
  add '/competitions', changefreq: 'monthly'
  add '/skaters', changefreq: 'monthly'
  add '/scores', changefreq: 'monthly'
  add '/elements', changefreq: 'monthly'
  add '/components', changefreq: 'monthly'

  Competition.find_each do |competition|
    add competition_path(competition.short_name)
    #add url_for(controller: :competitions, action: :show, short_name: competition.short_name, host: Settings.about.site_url)
  end

  Skater.having_scores.find_each do |skater|
    add skater_path(skater.isu_number || skater.name)
    #add url_for(controller: :skaters, action: :show, isu_number: skater.isu_number || skater.name, host: Settings.about.site_url)
  end
end
