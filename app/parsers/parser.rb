class Parser
  include HttpGet
  include DebugPrint

=begin
  def self.parse(*args)
    self.new.parse(*args)
  end
=end

  def initialize(verbose: false)
    @verbose = verbose
  end
end
