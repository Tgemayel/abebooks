require 'net/http'
require 'json'
require 'uri'

class AbeBooks
  private
  
  def make_request(url, method: :get, payload: {})
    uri = URI(url)
    
    response = case method
    when :get
      uri.query = URI.encode_www_form(payload)
      Net::HTTP.get_response(uri)
    when :post
      Net::HTTP.post(uri, URI.encode_www_form(payload))
    end
    
    raise response.message unless response.is_a?(Net::HTTPSuccess)
    JSON.parse(response.body)
  end

  BASE_URL = 'https://www.abebooks.com/servlet'

  def get_price(payload)
    make_request("#{BASE_URL}/DWRestService/pricingservice", method: :post, payload: payload)
  end

  def get_recommendations(payload)
    make_request("#{BASE_URL}/RecommendationsApi", payload: payload)
  end

  public

  def search_by_keyword(keyword, options = {})
    payload = {
      'action' => 'search',
      'keyword' => keyword,
      'sortBy' => options[:sort_by] || 'relevance',
      'pageNum' => options[:page] || 1,
      'pageSize' => options[:per_page] || 20
    }.merge(options)
    
    make_request("#{BASE_URL}/SearchResults", payload: payload)
  end

  def get_book_details(book_id)
    make_request("#{BASE_URL}/BookDetails", payload: { 'bi' => book_id })
  end

  def search_by_publisher(publisher, options = {})
    search_by_keyword(publisher, { publisher: true }.merge(options))
  end

  def get_seller_info(seller_id)
    make_request("#{BASE_URL}/SellerProfile", payload: { 'sellerId' => seller_id })
  end

  def search_by_condition(condition, options = {})
    valid_conditions = ['new', 'used', 'collectible']
    raise ArgumentError, "Invalid condition. Must be: #{valid_conditions.join(', ')}" unless valid_conditions.include?(condition)
    
    search_options = {
      'condition' => condition,
      'filterBy' => 'condition'
    }.merge(options)
    
    make_request("#{BASE_URL}/SearchResults", payload: search_options)
  end

  def search_by_price_range(min_price, max_price, currency = 'USD', options = {})
    payload = {
      'minPrice' => min_price,
      'maxPrice' => max_price,
      'currency' => currency
    }.merge(options)
    
    make_request("#{BASE_URL}/SearchResults", payload: payload)
  end

  def search_by_year(year_from, year_to = nil, options = {})
    payload = {
      'yearFrom' => year_from,
      'yearTo' => year_to || year_from
    }.merge(options)
    
    make_request("#{BASE_URL}/SearchResults", payload: payload)
  end

  def search_by_location(country, state = nil, city = nil, options = {})
    payload = {
      'country' => country,
      'state' => state,
      'city' => city
    }.compact.merge(options)
    
    make_request("#{BASE_URL}/SearchResults", payload: payload)
  end

  def get_price_by_isbn(isbn)
    payload = {
      'action' => 'getPricingDataByISBN',
      'isbn' => isbn,
      'container' => "pricingService-#{isbn}"
    }
    get_price(payload)
  end

  def get_price_by_author_title(author, title)
    payload = {
      'action' => 'getPricingDataForAuthorTitleStandardAddToBasket',
      'an' => author,
      'tn' => title,
      'container' => 'oe-search-all'
    }
    get_price(payload)
  end

  def get_price_by_author_title_binding(author, title, binding)
    container = case binding
                when 'hard' then 'priced-from-hard'
                when 'soft' then 'priced-from-soft'
                else raise ArgumentError, 'Invalid parameter. Binding must be "hard" or "soft"'
                end

    payload = {
      'action' => 'getPricingDataForAuthorTitleBindingRefinements',
      'an' => author,
      'tn' => title,
      'container' => container
    }
    get_price(payload)
  end

  def get_recommendations_by_isbn(isbn)
    payload = {
      'pageId' => 'plp',
      'itemIsbn13' => isbn
    }
    get_recommendations(payload)
  end
end
