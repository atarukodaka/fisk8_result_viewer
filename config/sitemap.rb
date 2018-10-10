# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = Settings.about.site_url

SitemapGenerator::Sitemap.create do
  add '/competitions', changefreq: 'monthly'
  add '/skaters', changefreq: 'monthly'
  add '/scores', changefreq: 'monthly'
  add '/elements', changefreq: 'monthly'
  add '/components', changefreq: 'monthly'
  add '/panels', changefreq: 'monthly'

  Competition.find_each do |competition|
    add competition_path(competition.short_name)
  end

  Skater.having_scores.find_each do |skater|
    add skater_path(skater.isu_number || skater.name)
  end
end
