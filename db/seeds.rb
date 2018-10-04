####
# category

[
  ### SENIOR
  {
    name:          'MEN',
    isu_bio_url:   'http://www.isuresults.com/bios/fsbiosmen.htm',
    abbr:          'SM',
    seniority:     'SENIOR',
    team:          false,
    category_type: 'MEN',
  },
  {
    name:          'LADIES',
    isu_bio_url:   'http://www.isuresults.com/bios/fsbiosladies.htm',
    abbr:          'SL',
    seniority:     'SENIOR',
    team:          false,
    category_type: 'LADIES',
  },
  {
    name:          'PAIRS',
    isu_bio_url:   'http://www.isuresults.com/bios/fsbiospairs.htm',
    abbr:          'SP',
    seniority:     'SENIOR',
    team:          false,
    category_type: 'PAIRS',
  },
  {
    name:          'ICE DANCE',
    isu_bio_url:   'http://www.isuresults.com/bios/fsbiosicedancing.htm',
    abbr:          'SD',
    seniority:     'SENIOR',
    team:          false,
    category_type: 'ICE DANCE',
  },
  #### JUNIOR
  {
    name:          'JUNIOR MEN',
    abbr:          'JM',
    seniority:     'JUNIOR',
    team:          false,
    category_type: 'MEN',
  },
  {
    name:          'JUNIOR LADIES',
    abbr:          'JL',
    seniority:     'JUNIOR',
    team:          false,
    category_type: 'LADIES',
  },
  {
    name:          'JUNIOR PAIRS',
    abbr:          'JP',
    seniority:     'JUNIOR',
    team:          false,
    category_type: 'PAIRS',
  },
  {
    name:          'JUNIOR ICE DANCE',
    abbr:          'JD',
    seniority:     'JUNIOR',
    team:          false,
    category_type: 'ICE DANCE',
  },
  #### TEAM
  {
    name:          'TEAM MEN',
    abbr:          'TM',
    seniority:     'SENIOR',
    team:          true,
    category_type: 'MEN',
  },
  {
    name:          'TEAM LADIES',
    abbr:          'TL',
    seniority:     'SENIOR',
    team:          true,
    category_type: 'LADIES',
  },
  {
    name:          'TEAM PAIRS',
    abbr:          'TP',
    seniority:     'SENIOR',
    team:          true,
    category_type: 'PAIRS',
  },
  {
    name:          'TEAM ICE DANCE',
    abbr:          'TD',
    seniority:     'SENIOR',
    team:          true,
    category_type: 'ICE DANCE',
  },
].each do |elem|
  Category.find_or_create_by(name: elem[:name]) do |category|
    category.update(elem)
  end
end

####
# segment
[
  {
    name:         'SHORT PROGRAM',
    abbr:         'SP',
    segment_type: 'short',
  },
  {
    name:         'FREE SKATING',
    abbr:         'FS',
    segment_type: 'free',
  },
  ## for ice dance
  {
    name:         'SHORT DANCE',
    abbr:         'SD',
    segment_type: 'short',
  },
  {
    name:         'RHYTHM DANCE',
    abbr:         'RD',
    segment_type: 'short',
  },
  {
    name:         'FREE DANCE',
    abbr:         'FD',
    segment_type: 'free',
  },
].each do |elem|
  #Segment.create(elem)
  Segment.find_or_create_by(name: elem[:name]) do |segment|
    segment.update(elem)
  end
end
