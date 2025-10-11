require_relative '../../lib/election_scraper'

class Autarquicas2021 < ElectionScraper::Base
  ELECTION_URL = 'https://www.eleicoes.mai.gov.pt/autarquicas2021/resultados/territorio-nacional'
  OUTPUT_FILE = File.join(__dir__, 'data', 'autarquicas2021.csv')
  
  def initialize
    super
    # Ensure the data directory exists
    FileUtils.mkdir_p(File.join(__dir__, 'data'))
  end
  
  def scrape_all
    puts "Iniciando scraper das Autárquicas 2021..."
    navigate_to(ELECTION_URL)
    sleep 2 # Give the page time to load initially
    
    districts = get_districts
    puts "Encontrados #{districts.size} distritos"
    
    districts.each do |distrito|
      puts "\nProcessando distrito: #{distrito}"
      municipalities = get_municipalities(distrito)
      puts "Encontrados #{municipalities.size} concelhos em #{distrito}"
      
      municipalities.each do |concelho|
        puts "  Processando concelho: #{concelho}"
        parishes = get_parishes(distrito, concelho)
        puts "  Encontradas #{parishes.size} freguesias em #{concelho}"
        
        parishes.each do |freguesia|
          puts "    Processando freguesia: #{freguesia}"
          scrape_location(distrito, concelho, freguesia, OUTPUT_FILE)
          sleep 1
        end
      end
    end
    
    puts "\nScraping concluído! Resultados salvos em: #{OUTPUT_FILE}"
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