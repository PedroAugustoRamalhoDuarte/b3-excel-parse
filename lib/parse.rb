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
      total_bought_price, bought_amount = bought_info(transactions)
      amount = product_amount(transactions)
      average_bought_price = bought_amount != 0 ? (total_bought_price / bought_amount) : 0
      [amount, average_bought_price, amount * average_bought_price]
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

    # @return [total_bought_price, total_bought_amount]
    def bought_info(transactions)
      total_price = 0
      amount = 0
      transactions.each do |t|
        price = 0
        if t[TYPE] == 'Transferência - Liquidação' && t[SIDE] == 'Credito'
          price = t[TOTAL_PRICE]
          amount += t[QTD].to_i
        end
        price = 0 if price.is_a?(String)
        total_price += price
      end
      [total_price, amount]
    end

    def amount_to_sum(row)
      return row[QTD].to_i if row[TYPE] == 'Transferência - Liquidação' && row[SIDE] == 'Credito'
      return -row[QTD].to_i if row[TYPE] == 'Transferência - Liquidação' && row[SIDE] == 'Debito'

      0
    end
  end
end
