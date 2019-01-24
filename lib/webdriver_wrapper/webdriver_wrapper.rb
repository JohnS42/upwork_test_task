require 'selenium-webdriver'

require_relative 'helpers/chrome_helper'
require_relative 'helpers/firefox_helper'
require_relative 'helpers/webdriver_helper'

module WebdriverWrapper
  DEFAULT_WAIT_UNTIL_TIMEOUT = 30
  DEFAULT_CHROMEDRIVER_BINARY_RELATIVE_PATH = 'bin/chromedriver'.freeze
  DEFAULT_GECKODRIVER_BINARY_RELATIVE_PATH = 'bin/geckodriver'.freeze

  class WebDriver
    include ChromeHelper
    include FirefoxHelper
    include WebdriverHelper

    attr_accessor :driver

    def initialize(browser = :chrome)
      case browser
      when :chrome
        @driver = start_chrome_driver
      when :firefox
        @driver = start_firefox_driver
      else
        raise "Invalid browser param given = #{browser}, valid params: ':chrome' or ':firefox'"
      end
    end
  end
end
