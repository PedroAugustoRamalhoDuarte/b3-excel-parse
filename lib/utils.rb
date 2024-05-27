# frozen_string_literal: true

module B3ExcelParse
  module Utils
    def format_price(price, hide: true)
      return '-' if hide && price.zero?

      "R$ #{format('%.2f', price).gsub('.', ',')}"
    end
  end
end
