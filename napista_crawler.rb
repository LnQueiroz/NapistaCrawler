require 'mechanize'
require 'json'
require 'dotenv/load'


class Car
  NUMBER_PATTERN = /\d+/i
  BRAND_PATTERN = /^(Land\sRover|CAOA\sCHERY|VW\sTRUCK\sE\sBUS|[\w-]+)/i

  attr_reader :brand, :model, :price, :year, :src_path, :local_path

  # Initializes a new instance of Car.
  #
  # @param page [Mechanize::Page] The HTML page containing the car information.
  def initialize(page)
    page = page.click
    @brand, @model = get_brand_model(page)
    @price = get_price(page)
    @year = get_year(page)
    @src_path = page.css('img').first['src']
    @local_path = download_image("#{brand}-#{year}", @src_path)
  end

  # Converts the car information into a hash.
  #
  # @return [Hash] The car information as a hash.
  def to_hash
    {
      "modelo" => @model,
      "marca" => @brand,
      "valor" => @price,
      "ano" => @year,
      "src_path" => @src_path,
      "local_path" => @local_path
    }
  end

  private

  # Retrieves the car price from the page.
  #
  # @param car_page [Mechanize::Page] The HTML page containing the car information.
  # @return [String] The car price.
  def get_price(car_page)
    price_text = car_page.at_css('.sc-b35e10ef-0.iyypHF').children.text[3..-1]
    price_text = price_text.scan(NUMBER_PATTERN)
    sprintf('%.2f', price_text.join("").to_f)
  end

  # Retrieves the car brand and model from the page.
  #
  # @param car_page [Mechanize::Page] The HTML page containing the car information.
  # @return [Array<String>] The car brand and model.
  def get_brand_model(car_page)
    model_and_name = car_page.css('h1').children.text
    model_and_name.split(BRAND_PATTERN)[1, 2]
  end

  # Retrieves the car year from the page.
  #
  # @param car_page [Mechanize::Page] The HTML page containing the car information.
  # @return [String] The car year.
  def get_year(car_page)
    car_page.css('li')[0].children.children.last.text
  end

  # Downloads the car image and saves it locally.
  #
  # @param car_filename [String] The car file name.
  # @param img_path [String] The car image path.
  # @return [String] The local path where the image was saved.
  def download_image(car_filename, img_path)
    folder_path = "#{ENV['RESULT_PATH']}/Images"
    unless File.directory?(folder_path)
      Dir.mkdir(folder_path)
      puts "Folder to store car images created successfully at #{folder_path}"
    end
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    filename = "#{folder_path}/#{car_filename}-#{timestamp}"
    agent = Mechanize.new
    agent.get(img_path).save(filename)
    filename
  end
end

# Class responsible for performing web crawling and extracting information about cars.
class CarCrawler

  # Initializes a new instance of CarCrawler.
  def initialize
    @agent = Mechanize.new
    @result_path = ENV['RESULT_PATH']
    @url_napista_fb = ENV['URL_NAPISTA_FB']
  end

  # Executes the web crawling to extract information about cars.
  def run
    result = @agent.get @url_napista_fb
    create_folder(@result_path)
    json_result = generate_cars_json(result)
    save_json(json_result, "cars_info.json")
  end

  private
  # Generates a JSON containing information about the cars extracted from the search result.
  #
  # @param search_result [Mechanize::Page] The HTML page containing the search results.
  # @return [Array<HashMap>] An array of hashes containing the car information.
  def generate_cars_json(search_result)
    cars = search_result.links.select { |link| link.text.include?('km') }
    cars_json = []
    cars.each do |car|
      cars_json << Car.new(car).to_hash
    end
    cars_json
  end
 
  # Creates a folder if it doesn't exist.
  #
  # @param path [String] The path of the folder to create.
  def create_folder(path)
    unless File.directory?(path)
      Dir.mkdir(path)
      puts "Folder #{path} created successfully"
    end
  end

  # Saves the JSON to a file.
  #
  # @param json [Array<HashMap>] The JSON data to save.
  # @param path [String] The path where the JSON file will be saved.
  def save_json(json, path)
    File.open("#{@result_path}/#{path}", 'w') do |f|
      f.write(JSON.pretty_generate(json))
      puts "JSON file generated and saved in: #{@result_path}/#{path}"
    end
  end
end

car_crawler = CarCrawler.new
car_crawler.run
