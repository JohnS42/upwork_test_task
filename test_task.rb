require_relative 'framework/test_instance'

# TODO: add option parser
# browser = :chrome
browser = :firefox
keyword = 'test'

CleanUpHelper.kill_automation_related_entities
test = nil
page = nil
search_result_freelancers_parsed = nil
indexes_for_random_freelancer = nil

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

    step "Step #6: Parse the 1st page with search results: store info given on the 1st page of search results as structured data of any chosen by you type (i.e. hash of hashes or array of hashes, whatever structure handy to be parsed)." do
      page.parse_data
      search_result_freelancers_parsed = page.parsed_freelancers
      indexes_for_random_freelancer = page.freelancer_indexes
    end

    step "Step #7: Make sure at least one attribute (title, overview, skills, etc) of each item (found freelancer) from parsed search results contains `<keyword>` Log in stdout which freelancers and attributes contain `<keyword>` and which do not." do
      verification_data = page.freelancers_verification(keyword)
      expect(verification_data[:freelancers_without_keyword].empty?).to eq(true)
    end

    step "Step #8: Click on random freelancer's title" do
      random_title_no = indexes_for_random_freelancer.sample
      page = page.click_on_freelancer_title random_title_no
    end

    step "Step #9: Get into that freelancer's profile" do
      page = page.go_to_fullscreen_profile
    end

    test.webdriver.driver.quit
  end
end

upwork_test_suite.render_results
CleanUpHelper.kill_automation_related_entities
