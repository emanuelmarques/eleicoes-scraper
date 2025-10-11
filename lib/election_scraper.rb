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
      distrito_list = browser.select_lists(aria_label: 'Distrito/Região Autónoma')
      distrito_list[0].wait_until(&:present?).select(text: distrito)
      
      concelho_list = browser.select_lists(aria_label: 'Concelho')
      concelho_list[0].wait_until(&:present?).select(text: concelho)
      
      freguesia_list = browser.select_lists(aria_label: 'Freguesia')
      freguesia_list[0].wait_until(&:present?).select(text: freguesia)
      
      sleep 2
      scrape_results(distrito, concelho, freguesia, output_file)
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
      browser.goto url
      browser.link(text: 'Localidades').click
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