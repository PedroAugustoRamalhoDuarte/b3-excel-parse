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
      @rows = @sheet.simple_rows.drop(1) # Drop header line
    end

    def all_products
      @rows.map { |p| ticket(p[PRODUCT]) }.uniq
    end

    def product_transactions(product_name)
      @rows.filter { |row| ticket(row[PRODUCT]) == product_name }
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

    def product_yield(product_name)
      transactions = product_transactions(product_name)
      dividens = transactions.filter { |row| row[TYPE] == 'Dividendo' or row[TYPE] == 'Rendimento' }
      jpcs = transactions.filter { |row| row[TYPE] == 'Juros Sobre Capital Próprio' }
      [dividens, jpcs]
    end

    private

    def ticket(product_name)
      product_name.split[0]
    end

    def price_to_sum(row)
      price = row[TOTAL_PRICE] if row[TYPE] == 'Transferência - Liquidação' && row[SIDE] == 'Credito'
      price = -row[TOTAL_PRICE] if row[TYPE] == 'Transferência - Liquidação' && row[SIDE] == 'Debito'
      if price
        return 0 if price.is_a?(String)

        return price
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
