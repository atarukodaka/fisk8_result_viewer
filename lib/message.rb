module Message
  def self.silent
    @silent
  end

  def self.silent=(val)
    @silent = val
  end

  def message(msg, indent: 0)
    puts(' ' * indent + msg) unless Message.silent
  end
  module_function :message
end
