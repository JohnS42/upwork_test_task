require_relative 'framework/test_instance'

# Notes:
# Assuming user will use keyword matching regex \w+ (no logic for 2+ words as 'keyword')
# Assuming user have installed firefox and google chrome browser
#
# Tested on:
# OS: Ubuntu 16.04.5 LTS
# Firefox: firefox 64.0+build3-0ubuntu0.16.04.1
# Google Chrome: google-chrome-stable 71.0.3578.98-1

# Configurable browser and keyword
# possible options for browser :firefox, :chrome
# keyword must be 1 word in order to get valid results

# browser = :chrome
browser = :firefox
keyword = 'test'

test = nil
page = nil
search_result_freelancers_parsed = nil
indexes_for_random_freelancer = nil
random_parsed_data = nil
random_title_no = nil

upwork_test_suite = context 'Upwork Test Suite' do
  context 'Upwork Test Case' do
    step "Step #1: Run `#{browser}`" do
      test = TestInstance.new(browser)
    end

    step "Step #2: Clear `#{browser}` cookies" do
      test.clear_cookies
    end

    step 'Step #3: Go to www.upwork.com' do
      page = Upwork.new(test)
    end

    step 'Step #4: Focus onto "Find freelancers"' do
      page.focus_onto_find_freelancers
    end

    step "Step #5: Enter `#{keyword}` into the search input right from the dropdown and submit it (click on the magnifying glass button)" do
      page = page.search_for keyword
    end

    step 'Step #6: Parse the 1st page with search results: store info given on the 1st page of search results as structured data of any chosen by you type (i.e. hash of hashes or array of hashes, whatever structure handy to be parsed).' do
      page.parse_data
      search_result_freelancers_parsed = page.parsed_freelancers
      indexes_for_random_freelancer = page.freelancer_indexes
    end

    step "Step #7: Make sure at least one attribute (title, overview, skills, etc) of each item (found freelancer) from parsed search results contains `<#{keyword}>` Log in stdout which freelancers and attributes contain `<#{keyword}>` and which do not." do
      verification_data = page.freelancers_verification(keyword)
      expect(verification_data[:freelancers_without_keyword].empty?).to eq(true)
    end

    step "Step #8: Click on random freelancer's title" do
      random_title_no = indexes_for_random_freelancer.sample
      random_parsed_data = page.freelancer_data_by_index(random_title_no)
      page = page.click_on_freelancer_title random_title_no
    end

    step "Step #9: Get into that freelancer's profile" do
      page = page.go_to_fullscreen_profile
    end

    step 'Step #10: Check that each attribute value is equal to one of those stored in the structure created in #67' do
      results = page.compare_profile_data_with_stored_data(random_parsed_data)
      # since we are comparing only 4 attributes
      expect(results.find_all { |result| result.invert.keys.first == 'passed' }.size).to eq(4)
    end

    step "Step #11: Check whether at least one attribute contains `<#{keyword}>`" do
      results = page.keyword_presence_check(keyword)
      # since we need only 1 match
      expect(results.find_all { |result| result.invert.keys.first == 'keyword' }.size >= 1).to eq(true)
    end
  end
end

upwork_test_suite.render_results
