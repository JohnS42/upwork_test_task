module WebdriverWrapper
  module FirefoxHelper
    def geckodriver_path
      File.join(File.dirname(__FILE__), DEFAULT_GECKODRIVER_BINARY_RELATIVE_PATH)
    end

    def start_firefox_driver
      webdriver_options = { driver_path: geckodriver_path }
      driver = Selenium::WebDriver.for :firefox, webdriver_options
      driver.manage.window.maximize
      driver
    end
  end
end
