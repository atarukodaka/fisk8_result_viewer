class Segment < ActiveRecord::Base
  has_many :segment_results
  has_many :scores
end
__END__
  self.data =
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
        abbr: "SP",
        segment_type: "short",
      },
      {
        name: "RHYTHM DANCE",
        abbr: "SP",
        segment_type: "short",
      },
      {
        name: "FREE DANCE",
        abbr: "FS",
        segment_type: "free",
      },
    ]
end
