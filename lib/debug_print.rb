module DebugPrint
  #attr_accessor :verbose
  @@verbose = false

  def debug_logger
    @debug_logger ||= ActiveSupport::Logger.new(STDOUT, proc { |_s, _d, _p, msg| "#{msg}\n" })
  end

  def verbose(flag)
    @@verbose = flag
  end
  module_function :verbose

  def verbose?
    @@verbose
  end
  module_function :verbose?
  def debug(msg, indent: 0)
    debug_logger.debug(' ' * indent + msg) if @@verbose
  end
end
