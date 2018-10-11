class Updater
  using StringToModel
  include DebugPrint
  
  def initialize(verbose: false)
    @verbose = verbose
  end
end
