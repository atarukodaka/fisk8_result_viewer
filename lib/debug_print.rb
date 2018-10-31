module DebugPrint
  attr_accessor :verbose

  def debug_logger
    @debug_logger ||= ActiveSupport::Logger.new(STDOUT, proc { |_s, _d, _p, msg| "#{msg}\n" })
  end

  def debug(msg, indent: 0)
    debug_logger.debug(' ' * indent + msg) if verbose
  end
end
