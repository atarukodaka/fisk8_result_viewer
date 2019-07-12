class Parser
  include HttpGet
  include DebugPrint

  attr_accessor :verbose

  def initialize(verbose: false, encoding: 'iso-8859-1')
    @verbose = verbose
    @encoding = encoding
  end
end
