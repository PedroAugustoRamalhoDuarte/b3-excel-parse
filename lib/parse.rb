# frozen_string_literal: true

require 'creek'

module B3ExcelParse
  class Parse
    # Headers
    SIDE = 'Entrada/Saída'
    DATE = 'Data'
    TYPE = 'Movimentação'
    PRODUCT = 'Produto'
    BROKER = 'Instituição'
    QTD = 'Quantidade'
    UNIT_PRICE = 'Preço unitário'
    TOTAL_PRICE = 'Valor da Operação'

    def initialize(file_path)
      creek = Creek::Book.new file_path, with_headers: true
      @sheet = creek.sheets[0]
    end

    def all_products
      @sheet.simple_rows.map { |p| p[PRODUCT] }.uniq
    end

    def product_transactions(product_name)
      @sheet.simple_rows.filter { |row| row[PRODUCT] == product_name }
    end

    def product_amount(transactions)
      transactions.sum { |row| amount_to_sum(row) }
    end

    def product_info(product_name)
      transactions = product_transactions(product_name)
      total_price = transactions.sum { |row| price_to_sum(row) }
      amount = product_amount(transactions)
      [amount, total_price, (amount != 0 ? (total_price / amount) : 0)]
    end

    private

    def price_to_sum(row)

      price = row[TOTAL_PRICE] if row[TYPE] == 'Transferência - Liquidação' && row[SIDE] == 'Credito'
      price = -row[TOTAL_PRICE] if row[TYPE] == 'Transferência - Liquidação' && row[SIDE] == 'Debito'
      if price
        if price.is_a?(String)
          return 0
        else
          return price
        end
      end
      0
    end

    def amount_to_sum(row)
      return row[QTD].to_i if row[TYPE] == 'Transferência - Liquidação' && row[SIDE] == 'Credito'
      return -row[QTD].to_i if row[TYPE] == 'Transferência - Liquidação' && row[SIDE] == 'Debito'

      0
    end
  end
end