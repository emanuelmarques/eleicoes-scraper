# Instalação e Configuração

## Pré-requisitos

1. **Instalar Ruby (Windows)**
   - Baixe o Ruby+Devkit de https://rubyinstaller.org/downloads/
   - Recomendado: Ruby 3.0 ou superior com Devkit
   - Execute o instalador e selecione todas as opções padrão
   - Na última etapa, marque "Run 'ridk install'"
   - No terminal que abrir, pressione ENTER para instalar todas as dependências padrão

2. **Instalar Google Chrome**
   - Se ainda não tiver instalado, baixe de https://www.google.com/chrome/
   - O ChromeDriver será gerenciado automaticamente pelo selenium-webdriver

## Instalação das Dependências

1. **Instalar Bundler (gerenciador de dependências)**
   ```bash
   gem install bundler
   ```

2. **Instalar dependências do projeto**
   ```bash
   bundle install
   ```

## Executar os Scrapers

1. **Para as Autárquicas 2021:**
   ```bash
   ruby elections/autarquicas2021/scraper.rb
   ```

2. **Para as Legislativas 2022:**
   ```bash
   ruby elections/legislativas2022/scraper.rb
   ```

## Troubleshooting

Se encontrar erros:

1. **Erro de ChromeDriver:**
   - O ChromeDriver é instalado automaticamente
   - Se houver problemas, tente atualizar o Chrome para a última versão

2. **Erro de SSL/TLS:**
   ```bash
   gem update --system
   ```

3. **Erro de permissão no Windows:**
   - Execute o PowerShell como administrador