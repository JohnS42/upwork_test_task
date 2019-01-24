# TODO: add screenshot
# represents popup opened upon title click from search results
# https://www.upwork.com/o/profiles/browse/?nbs=1&q=test&profile=~01c0bd348053c0902d
class UpworkFreelancerProfilePopup
  # locators
  PROFILE_OPENER = { xpath: '//*[contains(@class, "fullscreen")]/parent::*/a' }.freeze

  def initialize(instance)
    @instance = instance
    wait_to_load
  end

  def go_to_fullscreen_profile
    # @instance.move_to PROFILE_OPENER
    @instance.click_to PROFILE_OPENER
    @instance.select_last_opened_tab
    UpworkFreelancerProfile.new(@instance)
  end

  private

  def wait_to_load
    @instance.wait_until { @instance.displayed?(PROFILE_OPENER) }
    MyLogger.log "Current page title: #{@instance.title}, url: #{@instance.current_url}"
  end
end
