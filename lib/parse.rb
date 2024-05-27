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
    # Na Bonificação em Ativo realmente não conseguimos calcular, porque o valor é baseado no valor dito pela empresa e não temos esse valor no excel
    # No desdobramento de ações a quantidade é a quantidade de ativos novos (Como se fosse uma operação de compra)
    # No grupamento de ações a quantidade é a quantidade final de ações após o grupoamento
    #   - Caso tenha um número fracionário: Em sequêcia teremos 2 eventos Leilão de fração e Fração em Ativos 
    WARN_KEYWORDS = ['Fração em Ativos', 'Fração em Ativos', 'Empréstimo', 'Bonificação em Ativos'].freeze
    # TODO: Handle Grupamento, Leilão de Fração 

    def initialize(files_path)
      @rows = []
      files_path.each do |file_path|
        creek = Creek::Book.new file_path, with_headers: true
        @sheet = creek.sheets[0]
        @rows += @sheet.simple_rows.drop(1) # Drop header line
      end
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

    def product_warning?(transactions)
      transactions.each { |row| return true if WARN_KEYWORDS.include?(row[TYPE]) }
      false
    end

    private

    def ticket(product_name)
      product_name.split[0]
    end

    # Informações de compra
    #   Para o cálculo segundo as fontes não precisamos levar em consideração as vendas
    #
    #   Fonte:
    #     - https://ajuda.nuinvest.com.br/hc/pt-br/articles/360049317813-Como-realizar-o-c%C3%A1lculo-do-Pre%C3%A7o-M%C3%A9dio
    # @return [total_bought_price, total_bought_amount]
    def bought_info(transactions)
      total_price = 0
      amount = 0
      transactions.each do |t|
        price = 0
        # TODO: Reduzir quantidade de items
        if t[TYPE] == 'Transferência - Liquidação' && t[SIDE] == 'Credito'
          price = t[TOTAL_PRICE]
          amount += t[QTD].to_i
        end
        if t[TYPE] == 'Desdobro'
          amount +=  t[QTD].to_i
        end
        if t[TYPE] == 'Grupamento'
          amount = t[QTD].to_i # Podemos ignorar as frações já que serão posteriormente leiloadas
        end
        price = 0 if price.is_a?(String)
        total_price += price
      end
      [total_price, amount]
    end

    def amount_to_sum(row)
      return row[QTD].to_i if row[TYPE] == 'Transferência - Liquidação' && row[SIDE] == 'Credito'
      return -row[QTD].to_i if row[TYPE] == 'Transferência - Liquidação' && row[SIDE] == 'Debito'
      return row[QTD].to_f if row[TYPE] == 'Desdobro'
      return -row[QTD].to_f if row[TYPE] == 'Fração em Ativos' && row[SIDE] == 'Debito'

      0
    end
  end
end
