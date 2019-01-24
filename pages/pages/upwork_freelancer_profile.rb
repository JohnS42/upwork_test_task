# TODO: add screenshot
# represents page https://www.upwork.com/o/profiles/users/_~01c0bd348053c0902d/
class UpworkFreelancerProfile
  # locators
  PROFILE_NAME = { xpath: '//*[@id="optimizely-header-container-default"]//*[@itemprop="name"]' }
  PROFILE_TITLE = { xpath: '//*[contains(@data-ng-bind-html, "vm.cfe.getProfileTitle() | htmlToPlaintext")]' }
  PROFILE_OVERVIEW = { xpath: '(//*[@id="optimizely-header-container-default"]//*[@itemprop="description"])[1]' }
  PROFILE_SKILLS = { xpath: '//*[contains(@class, "o-profile-skills")]' }

  attr_reader :profile_data

  def initialize(instance)
    @instance = instance
    wait_to_load
    parse_profile_data
  end

  def parse_profile_data
    MyLogger.log "Parse profile data"
    @profile_data = {
      name: @instance.text_of(PROFILE_NAME),
      title: @instance.text_of(PROFILE_TITLE),
      overview: @instance.text_of(PROFILE_OVERVIEW).gsub(/\s+/, ' '), # replacing all whitespace characters to match overview
      skills: @instance.text_of(PROFILE_SKILLS),
    }
    MyLogger.log "Parsed profile data: #{@profile_data}"
    @profile_data
  end

  # TODO: create custom matcher
  def compare_profile_data_with_stored_data(stored_data)
    MyLogger.log "Comparing stored data #{stored_data} vs #{@profile_data}"
    results = []

    # name
    if stored_data[:name] == @profile_data[:name]
      results << { name: 'passed' }
    else
      results << { name: 'failed', fail_message: "Expected <#{stored_data[:name]}> == <#{@profile_data[:name]}>" }
    end

    # title
    if stored_data[:title] == @profile_data[:title]
      results << { title: 'passed' }
    else
      results << { title: 'failed', fail_message: "Expected <#{stored_data[:title]}> == <#{@profile_data[:title]}>" }
    end

    # overview
    # handle overview's on search result page ' ...' character sequence
    stored_data[:overview] = stored_data[:overview][0..-5]
    if @profile_data[:overview].include?(stored_data[:overview])
      results << { overview: 'passed' }
    else
      results << { overview: 'failed', fail_message: "Expected <#{@profile_data[:overview]}> to include <#{stored_data[:overview]}>" }
    end

    # skills
    if @profile_data[:skills].include?(stored_data[:skills])
      results << { skills: 'passed' }
    else
      results << { skills: 'failed', fail_message: "Expected <#{@profile_data[:skills]}> to include <#{stored_data[:skills]}>" }
    end

    MyLogger.log "*********************"
    MyLogger.log "Upwork task step #10 results:"
    print JSON.pretty_unparse results
    print "\n\n"
    results
  end

  def keyword_presence_check(keyword)
    MyLogger.log "Checking #{keyword} presence in attributes #{@profile_data}"
    results = []

    # name
    if @profile_data[:name].downcase.include?(keyword.downcase)
      results << { name: 'keyword' }
    else
      results << { name: 'no keyword' }
    end

    # title
    if @profile_data[:title].downcase.include?(keyword.downcase)
      results << { title: 'keyword' }
    else
      results << { title: 'no keyword' }
    end

    # overview
    if @profile_data[:overview].downcase.include?(keyword.downcase)
      results << { overview: 'keyword' }
    else
      results << { overview: 'no keyword' }
    end

    # skills
    if @profile_data[:skills].downcase.include?(keyword.downcase)
      results << { skills: 'keyword' }
    else
      results << { skills: 'no keyword' }
    end

    MyLogger.log "*********************"
    MyLogger.log "Upwork task step #11 results:"
    print JSON.pretty_unparse results
    print "\n\n"
    results
  end

  private

  def wait_to_load
    @instance.wait_until { @instance.displayed?(PROFILE_NAME) }
    MyLogger.log "Current page title: #{@instance.title}, url: #{@instance.current_url}"
  end
end
