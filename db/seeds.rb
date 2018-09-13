# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

####
# category

[
  ### SENIOR
  {
    name: "MEN",
    isu_bio_url: "http://www.isuresults.com/bios/fsbiosmen.htm",
    abbr: "SM",
    seniority: "SENIOR",
  },
  {
    name: "LADIES",
    isu_bio_url: "http://www.isuresults.com/bios/fsbiosladies.htm",
    abbr: "SL",
    seniority: "SENIOR",
  },
  {
    name: "PAIRS",
    isu_bio_url: "http://www.isuresults.com/bios/fsbiospairs.htm",
    abbr: "SP",
    seniority: "SENIOR",
  },
  {
    name: "ICE DANCE",
    isu_bio_url: "http://www.isuresults.com/bios/fsbiosicedancing.htm",
    abbr: "SD",
    seniority: "SENIOR",
  },
  #### JUNIOR
  {
    name: "JUNIOR MEN",
    abbr: "JM",
    seniority: "JUNIOR",
  },
  {
    name: "JUNIOR LADIES",
      abbr: "JL",
      seniority: "JUNIOR",
  },
  {
    name: "JUNIOR PAIRS",
    abbr: "JP",
    seniority: "JUNIOR",
  },
  {
    name: "JUNIOR ICE DANCE",
    abbr: "JD",
    seniority: "JUNIOR",
  },
  #### TEAM
  {
    name: "TEAM MEN",
    abbr: "TM",
    seniority: "SENIOR",
  },
  {
    name: "TEAM LADIES",
    abbr: "TL",
    seniority: "SENIOR",
  },
  {
    name: "TEAM PAIRS",
    abbr: "TP",
    seniority: "SENIOR",
  },
  {
    name: "TEAM ICE DANCE",
    abbr: "TD",
    seniority: "SENIOR",
  },
  #### UNKNOWN
  {
    name: "UNKNOWN",
    abbr: "UK",
    seniority: "unknown",
  }
].each do |elem|
  Category.create(elem)
end

####
# segment
[
  {
    name: "SHORT PROGRAM",
    abbr: "SP",
    segment_type: "short",
  },
  {
    name: "FREE SKATING",
    abbr: "FS",
    segment_type: "free",
  },
  ## for ice dance
  {
    name: "SHORT DANCE",
    abbr: "SD",
    segment_type: "short",
  },
  {
    name: "RHYTHM DANCE",
    abbr: "RD",
    segment_type: "short",
  },
  {
    name: "FREE DANCE",
    abbr: "FD",
    segment_type: "free",
  },
].each do |elem|
  Segment.create(elem)
end
  
