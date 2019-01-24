require_relative '../lib/lib'
require_relative '../pages/pages'

class TestInstance
  attr_accessor :webdriver

  def initialize(browser = :chrome)
    MyLogger.log "Run #{browser}"
    @webdriver = WebdriverWrapper::WebDriver.new(browser)
    @webdriver
  end

  def clear_cookies(refresh = false)
    MyLogger.log 'Clearing browser cookies'
    loop do
      @webdriver.driver.manage.delete_all_cookies
      sleep 1
      break if @webdriver.driver.manage.all_cookies.empty?
    end
    refresh_page if refresh
  end

  def refresh_page
    MyLogger.log 'Refreshing browser'
    @webdriver.driver.navigate.refresh
    @webdriver.wait_until { @webdriver.js_loaded? }
  end

  def wait_until(timeout = WebdriverWrapper::DEFAULT_WAIT_UNTIL_TIMEOUT, message = nil, wait_js = true, &block)
    @webdriver.wait_until(timeout, message, wait_js, &block)
  end

  def displayed?(locator)
    MyLogger.log "Verifying element with locator '#{locator}' displayed"
    @webdriver.displayed?(locator)
  end

  def go_to_url(link)
    MyLogger.log "Navigating to <#{link}>"
    @webdriver.driver.navigate.to link
  end

  def current_url
    @webdriver.driver.current_url
  end

  def title
    @webdriver.driver.title
  end

  def type_to(where, what, clear = true)
    MyLogger.log "Type '#{what}' to element with locator #{where}, clearing element before type? #{clear}"
    @webdriver.type_to(where, what, clear)
  end

  def text_of(locator)
    MyLogger.log "Extracting text value of element with locator #{locator}"
    text_value = @webdriver.driver.find_element(locator).text
    MyLogger.log "Text value of element with locator #{locator}: <#{text_value}>"
    text_value
  end

  def attribute_value_of(locator, attribute)
    MyLogger.log "Extracting attribute #{attribute} value of element with locator #{locator}"
    attribute_value = @webdriver.driver.find_element(locator).attribute(attribute)
    MyLogger.log "Attribute #{attribute} value of element with locator #{locator}: #{attribute_value}"
    attribute_value
  end

  def click_to(where)
    MyLogger.log "Left Click to element with locator #{where}"
    @webdriver.click_to(where)
  end

  def move_to(where)
    MyLogger.log "Focus on element with locator #{where}"
    @webdriver.move_to(where)
  end

  def find_all_elements_with(locator)
    MyLogger.log "Find all elements with locator #{locator}"
    @webdriver.wait_until { !@webdriver.driver.find_elements(locator).empty? }
    @webdriver.driver.find_elements(locator)
  end

  def select_last_opened_tab
    MyLogger.log 'Select second browser tab'
    @webdriver.wait_until { @webdriver.tab_number > 1 }
    @webdriver.switch_to_last_tab
  end
end
