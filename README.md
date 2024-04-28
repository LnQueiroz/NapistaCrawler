## Crawler

This code is a web crawler designed to access "https://www.napista.com.br" website and retrieve all car listings in main page from Francisco Beltrão city. The crawler extracts specific information from these cars. Gemfile contains all required gems. Use bundler to install dependencies.

### Output

Here's an example of the output you can expect from running the crawler:

```json
[
  {
    "modelo": " S10 Blazer Dlx 2.5 Diesel Turbo",
    "marca": "Chevrolet",
    "valor": "45000.00",
    "ano": "2000",
    "src_path": "https://napista.com.br/static/photos/7a17dc20-4eb4-4070-9ed8-85bb8ed80a03_2f69292a-c81f-4a27-9455-bc0796ff1e81",
    "local_path": "images/Chevrolet-2000-20240428_134743"
  },
  {
    "modelo": " X1 Sdrive 20i X-line 2.0 Tb Active Flex",
    "marca": "Bmw",
    "valor": "149900.00",
    "ano": "2018",
    "src_path": "https://napista.com.br/static/photos/6130ae76-70f7-4e85-807f-48bb9644dd12_238b1c65-6036-4a45-9765-9662db417e20",
    "local_path": "images/Bmw-2018-20240428_134744"
  },
  ...
]
```

The term "local_path" indicates the file path where downloaded images of cars are stored. Upon running the crawler, a folder will be automatically generated to store these images.

The "src_path" denotes the website image source.

The JSON containing the list of cars will be generated and saved as "cars_info.json".
