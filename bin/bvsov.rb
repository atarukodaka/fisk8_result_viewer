
require 'csv'

def main
  filename = "dat/bvsov.csv"
  table = CSV.table(filename)
  table.each do |line|
    puts <<EOT
                        "#{line[0]}":
                                bv: [#{line[1]}, #{line[2] || 0}, #{line[3] || 0}]
                                sov: [#{line[4]}, #{line[5]}, #{line[6]}, #{line[7]}, #{line[8]}, #{line[9]}, #{line[10]}]
EOT
                  
    
  end
end

main
  
