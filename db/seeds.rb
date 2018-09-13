# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

[
  ### senior
  {
    name: "MEN",
    isu_bio_url: "http://www.isuresults.com/bios/fsbiosmen.htm",
    abbr: "SM",
    seniority: "senior",
  },
  {
    name: "LADIES",
    isu_bio_url: "http://www.isuresults.com/bios/fsbiosladies.htm",
    abbr: "SL",
    seniority: "senior",
  },
  {
    name: "PAIRS",
    isu_bio_url: "http://www.isuresults.com/bios/fsbiospairs.htm",
    abbr: "SP",
    seniority: "senior",
  },
  {
    name: "ICE DANCE",
    isu_bio_url: "http://www.isuresults.com/bios/fsbiosicedancing.htm",
    abbr: "SD",
    seniority: "senior",
  },
  #### junior
  {
    name: "JUNIOR MEN",
    abbr: "JM",
    seniority: "junior",
  },
  {
    name: "JUNIOR LADIES",
      abbr: "JL",
      seniority: "junior",
  },
  {
    name: "JUNIOR PAIRS",
    abbr: "JP",
    seniority: "junior",
  },
  {
    name: "JUNIOR ICE DANCE",
    abbr: "JD",
    seniority: "junior",
  },
  #### TEAM
  {
    name: "TEAM MEN",
    abbr: "TM",
    seniority: "senior",
  },
  {
    name: "TEAM LADIES",
    abbr: "TL",
    seniority: "senior",
  },
  {
    name: "TEAM PAIRS",
    abbr: "TP",
    seniority: "senior",
  },
  {
    name: "TEAM ICE DANCE",
    abbr: "TD",
    seniority: "senior",
  },
  #### UNKNOWN
  {
    name: "UNKNOWN",
    abbr: "UK",
    seniority: "unknown",
  }
].each do |elem|
  Category.create(name: elem[:name], abbr: elem[:abbr], seniority: elem[:seniority])
end
