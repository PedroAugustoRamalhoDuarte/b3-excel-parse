# frozen_string_literal: true

require 'creek'
creek = Creek::Book.new 'movimentacao.xlsx', with_headers: true
sheet = creek.sheets[0]

# Headers
SIDE = 'Entrada/Saída'
DATE = 'Data'
TYPE = 'Movimentação'
PRODUCT = 'Produto'
BROKER = 'Instituição'
QTD = 'Quantidade'
UNIT_PRICE = 'Preço unitário'
TOTAL_PRICE = 'Valor da Operação'

def product_transactions(sheet, product_name)
  sheet.simple_rows.filter { |row| row[PRODUCT] == product_name }
end

def parse_price(price)
  price.strip.split[1].to_f
end

def price_to_sum(row)
  return row[TOTAL_PRICE] if row[TYPE] == 'Transferência - Liquidação' && row[SIDE] == 'Credito'
  return -row[TOTAL_PRICE] if row[TYPE] == 'Transferência - Liquidação' && row[SIDE] == 'Debito'

  0
end

def amount_to_sum(row)
  return row[QTD].to_i if row[TYPE] == 'Transferência - Liquidação' && row[SIDE] == 'Credito'
  return -row[QTD].to_i if row[TYPE] == 'Transferência - Liquidação' && row[SIDE] == 'Debito'

  0
end

def product_amount(transactions)
  transactions.sum { |row| amount_to_sum(row) }
end

def average_price(sheet, product_name)
  transactions = product_transactions(sheet, product_name)
  sum = transactions.sum { |row| price_to_sum(row) }
  amount = product_amount(transactions)
  puts 'Quantidade: ', amount
  puts 'Preço Total Investido: ', amount
  puts 'Preço médio: ', amount / sum

end
