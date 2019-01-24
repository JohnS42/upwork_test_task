# TODO: add screenshot
# represents https://www.upwork.com/o/profiles/browse/?nbs=1&q=test page
class UpworkFreelancersSearchResults

  # locators
  # since there are also companies in search results
  FREELANCER_NAME = { xpath: '//h4[contains(@class, "display-inline-block")]/*[@data-qa="tile_name"]' }
  FREELANCER_TITLE = { xpath: '//h4[@data-qa="tile_title"]' }
  FREELANCER_OVERVIEW = { xpath: '//*[contains(@class, "d-lg-block")]/p[@data-qa="tile_description"]' }

  # entity all information container
  ENTITY_DATA = { xpath: '//article[contains(@class, "row")]' }

  # no results
  NO_RESULTS = { xpath: '//*[@data-qa="no_results"]' }

  attr_reader :freelancer_indexes
  attr_reader :agency_freelancer_indexes
  attr_reader :parsed_rows
  attr_reader :parsed_freelancers

  def initialize(instance)
    @instance = instance
    wait_to_load
    @freelancer_indexes = []
    @agency_freelancer_indexes = []
    @parsed_rows = []
    @parsed_freelancers = []
  end

  def freelancer_attributes
    (0..(@parsed_rows.size - 1)).each do |i|
      # TODO: add agencies parsing
      # for simplification - skipping agencies
      next if @agency_freelancer_indexes.include?(i)
      @parsed_freelancers << freelancer_data_by_index(i)
    end
    # TODO: add another options of output to MyLogger
    # for easier reading adding output without timestamps to STDOUT
    print JSON.pretty_unparse @parsed_freelancers
    @parsed_freelancers
  end

  def freelancer_data_by_index(index)
    {
      name: parse_row_name(index),
      title: parse_row_title(index),
      overview: parse_row_overview(index),
      skills: parse_row_skills(index)
    }
  end

  def parse_row_skills(index)
    MyLogger.log "Parsing skills of search result ##{index}"
    raw_skills = nil
    if @freelancer_indexes.include? index
      overview = parse_row_overview(index)
      skills_start_index = overview.size + @parsed_rows[index].index(overview) + 1
      raw_skills = @parsed_rows[index][skills_start_index..-1]
    elsif @agency_freelancer_indexes.include? index
      @instance.webdriver_error "Agency freelancer parsing is not yet implemented"
    else
      @instance.webdriver_error "Something went wrong - search result with ##{index} not found on page"
    end
    handle_raw_skills(raw_skills)
  end

  def handle_raw_skills(raw_skills)
    raw_skills.gsub!(/\d+ more/, '')
    raw_skills.gsub!(/Tests?: \d+/, '')
    raw_skills.gsub!(/Portfolios?: \d+/, '')
    # handling case when 0 skills
    return nil if raw_skills.size.zero?
    raw_skills.strip
  end

  def parse_row_name(index)
    MyLogger.log "Parsing name of search result ##{index}"
    result = @instance.find_all_elements_with(FREELANCER_NAME)[index].text
    MyLogger.log "Name of search result ##{index}: #{result}"
    result
  end

  def parse_row_title(index)
    MyLogger.log "Parsing title of search result ##{index}"
    result = @instance.find_all_elements_with(FREELANCER_TITLE)[index].text
    MyLogger.log "Title of search result ##{index}: #{result}"
    result
  end

  def parse_row_overview(index)
    MyLogger.log "Parsing overview of search result ##{index}"
    result = @instance.find_all_elements_with(FREELANCER_OVERVIEW)[index].text
    MyLogger.log "Overview of search result ##{index}: #{result}"
    result
  end

  def no_results?
    MyLogger.log "Check if nothing found"
    result = @instance.displayed?(NO_RESULTS)
    MyLogger.log "Nothing found: #{result}"
    result
  end

  # executed upon page load
  # in order to store indexes - assign them after first execution as instance variables
  def parse_data
    parse_rows
    retrieve_indexes
    freelancer_attributes
  end

  # since there is different layout for freelancer and agency freelancer search result
  def retrieve_indexes
    MyLogger.log "Parsing current page search results"
    return if no_results?
    @parsed_rows.each_with_index do |row, index|
      if row.downcase.include? 'relevant agency member'
        @agency_freelancer_indexes << index
      else
        @freelancer_indexes << index
      end
    end
    { freelancer_indexes: @freelancer_indexes, agency_freelancer_indexes: @agency_freelancer_indexes }
  end

  # since executed 1st time upon page load - lets store values as instance variables
  def parse_rows
    parse_rows_as_text
    # FIXME: not used in order to reduce complexity
    # TODO: possible option to parse agencies
    # parse_rows_as_raw_html
  end

  def parse_rows_as_text
    return if no_results?
    MyLogger.log "Parsing search results from current page"
    elements = @instance.find_all_elements_with ENTITY_DATA
    @parsed_rows = elements.map(&:text)
    @parsed_rows
  end

  def parse_rows_as_raw_html
    return if no_results?
    MyLogger.log "Parsing search results as raw html from current page"
    elements = @instance.find_all_elements_with ENTITY_DATA
    @html_rows = elements.map { |el| el.attribute('innerHTML') }
    @html_rows
  end

  # for test task #7
  # TODO: move to custom matcher
  # NOTE: using downcase since case is ignored by upwork search engine
  def freelancers_verification(keyword, print_results = true)
    freelancers_with_keyword = []
    freelancers_without_keyword = []
    @parsed_freelancers.each do |parsed_freelancer|
      attributes_with_keyword = []
      parsed_freelancer.invert.keys.each do |value|
        if value.downcase.include?(keyword.downcase)
          attributes_with_keyword << parsed_freelancer.invert[value]
        end
      end
      unless attributes_with_keyword.empty?
        freelancers_with_keyword << { freelancer_name: parsed_freelancer[:name], attributes_with_keyword: attributes_with_keyword }
      else
        freelancers_without_keyword << parsed_freelancer
      end
    end
    if print_results
      MyLogger.log "**************************************************"
      MyLogger.log "Keyword: <#{keyword}> step #7 results"
      MyLogger.log "Valid results:"
      print JSON.pretty_unparse freelancers_with_keyword
      print "\n\n"
      MyLogger.log "**************************************************"
      MyLogger.log "Invalid results:"
      print JSON.pretty_unparse freelancers_without_keyword
      print "\n\n"
      MyLogger.log "**************************************************"
    end
    { freelancers_with_keyword: freelancers_with_keyword, freelancers_without_keyword: freelancers_without_keyword }
  end

  def click_on_freelancer_title(index)
    MyLogger.log "Click on freelancer ##{index + 1} (name: #{parse_row_name(index)}, title = #{parse_row_title(index)})"
    locator = { FREELANCER_TITLE.keys.first => "(#{FREELANCER_TITLE.invert.keys.first})[#{index + 1}]" }
    @instance.click_to locator
    UpworkFreelancerProfilePopup.new(@instance)
  end

  private

  def wait_to_load
    @instance.wait_until do
      parse_rows.size > 0 || no_results?
    end
    MyLogger.log "Current page title: #{@instance.title}, url: #{@instance.current_url}"
  end
end
