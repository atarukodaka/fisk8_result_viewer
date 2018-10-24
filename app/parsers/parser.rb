class Parser
  include HttpGet
  include DebugPrint

  def self.parse(*args)
    self.new.parse(*args)
  end

  def initialize(verbose: false)
    @verbose = verbose
  end
end
