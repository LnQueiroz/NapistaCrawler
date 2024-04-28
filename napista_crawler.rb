require "mechanize"
require 'json'

$agent = Mechanize.new

def get_price(car_page)
    regex = /\d+/i
    price = car_page.at_css('.sc-b35e10ef-0.iyypHF').children.text[3..-1]
    price = price.scan(regex)
    price = sprintf('%.2f', price.join("").to_f)

    return price
end

def get_brand_model(car_page)
    regex = /^(Land\sRover|CAOA\sCHERY|VW\sTRUCK\sE\sBUS|[\w-]+)/i
    model_and_name = car_page.css('h1').children.text
    model_and_name = model_and_name.split(regex)
    return [model_and_name[1], model_and_name[2]]
end

def get_year(car_page)
    return car_page.css('li')[0].children.children.last.text
end

def download_image(car_filename, img_path)
    folder_path = 'images/'
    unless File.directory?(folder_path)
        Dir.mkdir(folder_path)
        puts "Folder to store car images created successfully at #{folder_path}"
    end
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    filename = "images/#{car_filename}-#{timestamp}"
    $agent.get(img_path).save(filename)
    return filename
end

def get_car_info(car)
    page = car.click
    brand, model = get_brand_model(page)
    price = get_price(page)
    year = get_year(page)
    img_path = page.css('img').first['src']
    local_path = download_image("#{brand}-#{year}", img_path)
    return {
        "modelo" => model,
        "marca" => brand,
        "valor" => price,
        "ano" => year,
        "src_path" => img_path,
        "local_path" => local_path
    }
end

def generate_cars_json(search_result)
    cars = search_result.links.select { |link| link.text.include?('km') }
    cars_json = []
    cars.each do |car|
        cars_json << get_car_info(car)
    end
    return cars_json
end

result = $agent.get "https://napista.com.br/busca/carro-em-francisco-beltrao"

json_result = generate_cars_json(result)

File.open('cars_info.json', 'w') do |f|
  f.write(JSON.pretty_generate(json_result))
  puts "JSON file generated and saved in: cars_info.json"
end