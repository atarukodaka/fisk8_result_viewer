####
# category

[
  ### SENIOR
  {
    name: "MEN",
    isu_bio_url: "http://www.isuresults.com/bios/fsbiosmen.htm",
    abbr: "SM",
    seniority: "SENIOR",
    indivisual: true,
    category_type: "MEN",
  },
  {
    name: "LADIES",
    isu_bio_url: "http://www.isuresults.com/bios/fsbiosladies.htm",
    abbr: "SL",
    seniority: "SENIOR",
    indivisual: true,
    category_type: "LADIES",
  },
  {
    name: "PAIRS",
    isu_bio_url: "http://www.isuresults.com/bios/fsbiospairs.htm",
    abbr: "SP",
    seniority: "SENIOR",
    indivisual: true,
    category_type: "PAIRS",
  },
  {
    name: "ICE DANCE",
    isu_bio_url: "http://www.isuresults.com/bios/fsbiosicedancing.htm",
    abbr: "SD",
    seniority: "SENIOR",
    indivisual: true,
    category_type: "ICE DANCE",
  },
  #### JUNIOR
  {
    name: "JUNIOR MEN",
    abbr: "JM",
    seniority: "JUNIOR",
    indivisual: true,
    category_type: "MEN",
  },
  {
    name: "JUNIOR LADIES",
    abbr: "JL",
    seniority: "JUNIOR",
    indivisual: true,
    category_type: "LADIES",
  },
  {
    name: "JUNIOR PAIRS",
    abbr: "JP",
    seniority: "JUNIOR",
    indivisual: true,
    category_type: "PAIRS",
  },
  {
    name: "JUNIOR ICE DANCE",
    abbr: "JD",
    seniority: "JUNIOR",
    indivisual: true,
    category_type: "ICE DANCE",
  },
  #### TEAM
  {
    name: "TEAM MEN",
    abbr: "TM",
    seniority: "SENIOR",
    indivisual: false,
    category_type: "MEN",
  },
  {
    name: "TEAM LADIES",
    abbr: "TL",
    seniority: "SENIOR",
    indivisual: true,
    category_type: "LADIES",
  },
  {
    name: "TEAM PAIRS",
    abbr: "TP",
    seniority: "SENIOR",
    indivisual: true,
    category_type: "PAIRS",
  },
  {
    name: "TEAM ICE DANCE",
    abbr: "TD",
    seniority: "SENIOR",
    indivisual: true,
    category_type: "ICE DANCE",
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
  
