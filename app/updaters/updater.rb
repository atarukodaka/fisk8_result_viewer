class Updater
  include DebugPrint

  attr_accessor :verbose

  def initialize(verbose: false)
    @verbose = verbose
  end
end
