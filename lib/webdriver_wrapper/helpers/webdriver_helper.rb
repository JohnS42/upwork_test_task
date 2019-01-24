module WebdriverWrapper
  module WebdriverHelper
    def wait_until(timeout = WebdriverWrapper::DEFAULT_WAIT_UNTIL_TIMEOUT, message = nil, wait_js = false, &block)
      wait = Object::Selenium::WebDriver::Wait.new(timeout: timeout, message: message)
      wait.until { js_loaded? } if wait_js
      wait.until(&block)
    rescue Selenium::WebDriver::Error::TimeOutError
      webdriver_error("Wait until timeout: #{timeout} seconds")
    rescue Selenium::WebDriver::Error::UnhandledAlertError
      webdriver_error('alert')
    end

    def webdriver_error(error_message)
      page_address = @driver.current_url
      page_address = "\n\nPage address: #{page_address}" unless page_address.nil?
      err_msg = "#{error_message}#{page_address}"
      raise RuntimeError, err_msg
    end

    def js_loaded?
      document_ready? && jquery_finished?
    end

    def jquery_loaded?
      execute_javascript('return !!window.jQuery')
    end

    def jquery_finished?
      return true unless jquery_loaded?
      execute_javascript('return window.jQuery.active;').zero?
    end

    def document_ready?
      execute_javascript('return document.readyState;') == 'complete'
    end

    def execute_javascript(script)
      @driver.execute_script(script)
    rescue Exception => e
      webdriver_error("Exception #{e} in execute_javascript: #{script}")
    end

    def displayed?(locator)
      @driver.find_element(locator).displayed?
      true
    rescue Selenium::WebDriver::Error::NoSuchElementError
      false
    end

    def click_to(locator)
      wait_until { displayed?(locator) }
      @driver.find_element(locator).click
    end

    def type_to(locator, what, clear = true)
      wait_until { displayed?(locator) }
      @driver.find_element(locator).clear if clear
      @driver.find_element(locator).send_keys what
    end

    def text_of(locator)
      wait_until { displayed?(locator) }
      @webdriver.driver.find_element(locator).text
    end

    def send_enter_to(locator)
      @driver.find_element(locator).send_keys :enter
    end

    def move_to(locator)
      element = @driver.find_element(locator)
      @driver.action.move_to(element).perform
    end

    def tab_number
      @driver.window_handles.length
    end

    def switch_to_last_tab
      @driver.switch_to.window(@driver.window_handles.last)
    end

    def switch_to_main_tab
      @driver.switch_to.window(@driver.window_handles.first)
    end
  end
end
