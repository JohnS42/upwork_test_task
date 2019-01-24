# TODO: add screenshot
# represents page https://www.upwork.com/o/profiles/users/_~01c0bd348053c0902d/
class UpworkFreelancerProfile
  # locators
  PROFILE_NAME = { xpath: '//*[@id="optimizely-header-container-default"]//*[@itemprop="name"]' }

  def initialize(instance)
    @instance = instance
    wait_to_load
  end

  private

  def wait_to_load
    @instance.wait_until { @instance.displayed?(PROFILE_NAME) }
    MyLogger.log "Current page title: #{@instance.title}, url: #{@instance.current_url}"
  end
end
