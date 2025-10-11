require_relative '../../lib/election_scraper'

class Autarquicas2021 < ElectionScraper::Base
  ELECTION_URL = 'https://www.eleicoes.mai.gov.pt/autarquicas2021/resultados/territorio-nacional'
  OUTPUT_FILE = File.join(__dir__, 'data', 'autarquicas2021.csv')
  
  def scrape_all
    navigate_to(ELECTION_URL)
    
    get_districts.each do |distrito|
      get_municipalities(distrito).each do |concelho|
        get_parishes(distrito, concelho).each do |freguesia|
          scrape_location(distrito, concelho, freguesia, OUTPUT_FILE)
          sleep 1
        end
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  scraper = Autarquicas2021.new
  begin
    scraper.scrape_all
  ensure
    scraper.close
  end
end