# TODO: add screenshot
# represents page https://www.upwork.com
class Upwork
  PAGE_URL = 'https://www.upwork.com'.freeze

  # locators
  SEARCH_BOX = { xpath: '(//*[contains(@class, "navbar-collapse")]//input[@type="search"])[2]' }.freeze
  MAGNIFYING_GLASS = { xpath: '(//button[@type="submit"]/span[1])[2]' }.freeze
  SEARCH_SWITCHER_OPENER = { xpath: '(//button[contains(@class, "dropdown-toggle")]/span[contains(@class, "air-icon-arrow-expand")])[3]' }.freeze
  SEARCH_FIND_FREELANCERS_SWITCHER = { xpath: '(//*[@id="search-dropdown"]/li[@data-label="Freelancers"]/a)[3]' }.freeze

  def initialize(instance)
    @instance = instance
    go_to
    wait_to_load
  end

  def go_to
    @instance.go_to_url PAGE_URL
  end

  def switch_to_find_freelancers
    return if is_search_type_freelancers?

    MyLogger.log "Switching search type to 'Find Freelancers'"
    @instance.click_to SEARCH_SWITCHER_OPENER
    @instance.wait_until { @instance.displayed?(SEARCH_FIND_FREELANCERS_SWITCHER) }
    @instance.move_to SEARCH_FIND_FREELANCERS_SWITCHER
    @instance.click_to SEARCH_FIND_FREELANCERS_SWITCHER
    @instance.wait_until { is_search_type_freelancers? }
  end

  def is_search_type_freelancers?
    @instance.attribute_value_of(SEARCH_BOX, 'placeholder').downcase.include? 'freelancers'
  end

  # assuming step #4 task was about search type switching logic if needed
  def focus_onto_find_freelancers
    switch_to_find_freelancers
    @instance.move_to SEARCH_BOX
  end

  def search_for(search_term)
    @instance.type_to(SEARCH_BOX, search_term)
    @instance.click_to MAGNIFYING_GLASS
    UpworkFreelancersSearchResults.new(@instance)
  end

  private

  def wait_to_load
    @instance.wait_until { @instance.displayed?(SEARCH_BOX) }
    MyLogger.log "Current page title: #{@instance.title}, url: #{@instance.current_url}"
  end
end
