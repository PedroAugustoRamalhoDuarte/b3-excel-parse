# frozen_string_literal: true

module B3ExcelParse
  module Utils
    def format_price(price)
      "R$ #{format('%.2f', price)}"
    end
  end
end
