require 'watir'
require 'csv'

module ElectionScraper
  class Base
    attr_reader :browser, :col_sep

    def initialize
      @col_sep = '|'
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument('--headless') # Run in headless mode for CI
      options.add_argument('--no-sandbox')
      options.add_argument('--disable-dev-shm-usage')
      
      client = Watir::HttpClient.new
      @browser = Watir::Browser.new :chrome, options: options, http_client: client
      @browser.window.move_to 1400, 0
    end

    def scrape_location(distrito, concelho, freguesia, output_file)
      retry_count = 0
      max_retries = 3
      
      begin
        # Wait for the district select to be present and enabled
        distrito_list = browser.select_list(aria_label: 'Distrito/Região Autónoma')
        distrito_list.wait_until(&:present?)
        distrito_list.wait_until(&:enabled?)
        distrito_list.select(text: distrito)
        sleep 1
        
        # Wait for concelho select to be present and enabled
        concelho_list = browser.select_list(aria_label: 'Concelho')
        concelho_list.wait_until(&:present?)
        concelho_list.wait_until(&:enabled?)
        concelho_list.select(text: concelho)
        sleep 1
        
        # Wait for freguesia select to be present and enabled
        freguesia_list = browser.select_list(aria_label: 'Freguesia')
        freguesia_list.wait_until(&:present?)
        freguesia_list.wait_until(&:enabled?)
        freguesia_list.select(text: freguesia)
        sleep 2
        
        scrape_results(distrito, concelho, freguesia, output_file)
      rescue Watir::Exception::UnknownObjectException, Watir::Exception::NoMatchingOptionError => e
        retry_count += 1
        if retry_count <= max_retries
          puts "Retrying #{distrito}/#{concelho}/#{freguesia} (attempt #{retry_count}/#{max_retries})"
          sleep 2 * retry_count
          retry
        else
          puts "Failed to scrape #{distrito}/#{concelho}/#{freguesia} after #{max_retries} attempts: #{e.message}"
          raise
        end
      end
    end

    def scrape_results(distrito, concelho, freguesia, output_file)
      rows = browser.divs(class: 'chart-row')
      row_arr = []
      rows.each { |td| row_arr << td.text.to_s.gsub("\n", ' | ') }
      content = row_arr.reject(&:empty?).join(', ').gsub('votos, ', '| ')
      content = content.gsub(/\s+/, '').gsub('votos', '').split('|')
      
      CSV.open(output_file, 'a+', col_sep: col_sep,
                                headers: %w[Distrito Concelho Freguesia Partido Voto(%) Votos]) do |csv|
        csv << [distrito.to_s, concelho.to_s, freguesia.to_s].push(*content)
      end
    end

    def navigate_to(url)
      # Add CM parameter if it's autarquicas2021
      url = "#{url}?election=CM" if url.include?('autarquicas2021')
      browser.goto url
      
      # Wait and try to find the navigation element
      begin
        # Try different possible selectors for the Localidades navigation
        if browser.link(text: 'Localidades').present?
          browser.link(text: 'Localidades').click
        elsif browser.link(text: 'Por Local').present?
          browser.link(text: 'Por Local').click
        elsif browser.button(text: /Local|Localidades/).present?
          browser.button(text: /Local|Localidades/).click
        elsif browser.element(role: 'tab', text: /Local|Localidades/).present?
          browser.element(role: 'tab', text: /Local|Localidades/).click
        else
          puts "Warning: Could not find Localidades navigation. The page might already be in the correct view."
        end
        sleep 2 # Wait for navigation to complete
      rescue => e
        puts "Warning: Error during navigation: #{e.message}. Continuing anyway..."
      end
    end

    def close
      browser.close
    end

    def get_districts
      distrito = browser.select_lists(aria_label: 'Distrito/Região Autónoma')
      a = []
      distrito.each { |e| a << e.innertext }
      a[0].to_s.split(/\n+/).drop(1)
    end

    def get_municipalities(distrito)
      distrito_list = browser.select_lists(aria_label: 'Distrito/Região Autónoma')
      distrito_list[0].wait_until(&:present?).select(text: distrito)
      sleep 1
      
      concelho = browser.select_lists(aria_label: 'Concelho')
      a = []
      concelho.each { |e| a << e.innertext }
      a[0].to_s.split(/\n+/).drop(1)
    end

    def get_parishes(distrito, concelho)
      distrito_list = browser.select_lists(aria_label: 'Distrito/Região Autónoma')
      distrito_list[0].wait_until(&:present?).select(text: distrito)
      
      concelho_list = browser.select_lists(aria_label: 'Concelho')
      concelho_list[0].wait_until(&:present?).select(text: concelho)
      sleep 1
      
      freguesia = browser.select_lists(aria_label: 'Freguesia')
      a = []
      freguesia.each { |e| a << e.innertext }
      a[0].to_s.split(/\n+/).drop(1)
    end
  end
end