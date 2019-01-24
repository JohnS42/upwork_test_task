require 'logger'

class MyLogger
  @logger = Logger.new(STDOUT)
  @logger.level = Logger::DEBUG

  def self.log(message)
    @logger.debug message
  end
end
