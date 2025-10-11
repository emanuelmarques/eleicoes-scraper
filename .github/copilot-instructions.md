# Copilot Instructions for AI Agents

## Project Overview
This repository contains Ruby scripts and CSV data for scraping and analyzing Portuguese election results by parish (freguesia). Currently supports the January 2022 legislative elections and 2021 local elections. The data is sourced from official MAI websites and is provided in CSV format.

## Project Structure
```
eleicoes-scraper/
├── lib/
│   └── election_scraper.rb      # Base scraping functionality
├── elections/
│   ├── autarquicas2021/
│   │   ├── data/               # CSV output files
│   │   └── scraper.rb         # Autarquicas specific scraper
│   └── legislativas2022/
│       ├── data/               # CSV output files
│       └── scraper.rb         # Legislativas specific scraper
```

## Key Components
- `lib/election_scraper.rb`: Core scraping functionality shared across all election types
- `elections/*/scraper.rb`: Election-specific scraper implementation
- `elections/*/data/*.csv`: Election results in CSV format
- `fuzzy.rb`: Utility for fuzzy matching parish names

## Data Flow
1. **Base Scraping**: `ElectionScraper::Base` provides common scraping functionality
2. **Election-Specific Logic**: Each election type has its own scraper class
3. **Data Organization**: Results are stored in election-specific data directories

## Developer Workflows
- **Run the Scraper**: Execute `ruby scrape.rb` from the project root to fetch and process election data.
- **Dependencies**: The project uses only standard Ruby libraries; no Gemfile or external dependencies are present.
- **Data Update**: To refresh data, re-run the scraper. Existing CSVs will be overwritten.

## Project Conventions
- Scripts are written in Ruby and expect to be run from the project root.
- Data files are always output as CSV in the root directory.
- Fuzzy matching is handled via `fuzzy.rb`—refer to this file for custom matching logic.
- No automated tests or CI/CD are present; manual validation is required.

## Integration Points
- **External Source**: Data is scraped from https://www.legislativas2022.mai.gov.pt/resultados/territorio-nacional
- **Visualization**: DataWrapper-compatible CSV is generated for visualization purposes.

## Example Usage
```sh
ruby scrape.rb
```

## Additional Notes
- For any changes to scraping logic, update both `scrape.rb` and `page_scrape.rb` as needed.
- If new data columns are added, ensure both CSV outputs are updated accordingly.
- For fuzzy matching improvements, edit `fuzzy.rb` and re-run the scraper.
