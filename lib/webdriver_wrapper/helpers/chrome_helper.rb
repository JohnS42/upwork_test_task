module WebdriverWrapper
  module ChromeHelper
    def chromedriver_path
      File.join(File.dirname(__FILE__), DEFAULT_CHROMEDRIVER_BINARY_RELATIVE_PATH)
    end

    def start_chrome_driver
      webdriver_options = { driver_path: chromedriver_path }
      driver = Selenium::WebDriver.for :chrome, webdriver_options
      driver.manage.window.maximize
      driver
    end
  end
end
