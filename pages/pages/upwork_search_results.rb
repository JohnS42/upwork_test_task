# TODO: add screenshot
# represents https://www.upwork.com/o/profiles/browse/?nbs=1&q=test page
class UpworkSearchResults

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

  def initialize(instance)
    @instance = instance
    wait_to_load
    @freelancer_indexes = []
    @agency_freelancer_indexes = []
    @parsed_rows = []
    parse_data
  end

  def freelancer_attributes
    attributes = []
    (0..(@parsed_rows.size - 1)).each do |i|
      # TODO: add agencies parsing
      # for simplification - skipping agencies
      next if @agency_freelancer_indexes.include?(i)
      attributes << {
        name: parse_row_name(i),
        title: parse_row_title(i),
        overview: parse_row_overview(i),
        skills: parse_row_skills(i)
      }
    end
    # TODO: add another options of output to MyLogger
    # for easier reading adding output without timestamps to STDOUT
    print JSON.pretty_unparse attributes
    attributes
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

  private

  def wait_to_load
    @instance.wait_until do
      parse_rows.size > 0 || no_results?
    end
    MyLogger.log "Current page title: #{@instance.title}, url: #{@instance.current_url}"
  end
end
