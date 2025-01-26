# Ruby Wrapper for AbeBooks.com REST API

## Installation

```ruby
gem install abebooks
```

## Usage

Search book prices by ISBN:

```ruby
require 'abebooks'

ab = AbeBooks.new
results = ab.get_price_by_isbn('9780062941503')
if results['success']
  best_new = results['pricingInfoForBestNew']
  best_used = results['pricingInfoForBestUsed']

  # Best New Price
  puts best_new['bestPriceInPurchaseCurrencyWithCurrencySymbol']
  # Best Used Price
  puts best_used['bestPriceInPurchaseCurrencyWithCurrencySymbol']
end
```

Search by keyword:
```ruby
results = ab.search_by_keyword('ruby programming', sort_by: 'price_low')
```

Search by price range:
```ruby
books = ab.search_by_price_range(10, 50, 'USD')
```

Search by year:
```ruby
vintage_books = ab.search_by_year(1950, 1960)
```

Get seller information:
```ruby
seller = ab.get_seller_info('seller123')
```

