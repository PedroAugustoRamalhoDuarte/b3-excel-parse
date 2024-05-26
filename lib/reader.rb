# frozen_string_literal: true

require_relative "./parse"
require_relative "./utils"

module B3ExcelParse
  class Reader
    include B3ExcelParse::Utils

    def initialize(file_path)
      @rows = File.readlines(file_path)
    end

    DIVIDENDOS = '8408810674405T0881067440500'.freeze
    BENS_E_DIREITO = '2708810674405010105'.freeze
    # Bens e direito
    def bi
      ri = @rows.filter { |row| row.include?(BENS_E_DIREITO) }
      ri.map do |row|
        {
          name: row[19..530].strip,
          value: row[544..].to_f / 100.0, # Ano atual
        }
      end
    end

    def write
      parse = Parse.new(["./tmp/movimentacoes2022.xlsx", "./tmp/movimentacoes2023.xlsx"])
      rows = parse.all_products.map do |product_name|
        amount, avg_price , total_price = parse.product_info(product_name)
        warning = parse.product_warning?(parse.product_transactions(product_name))
        product_name += " - #{amount.to_i}"
        [product_name, total_price] if amount.positive?
      end.compact

      rows.each do |row|
        puts "2708810674405010105#{insert_blank_spaces(row[0])}#{insert_zeros(0)}#{insert_zeros((row[1] * 100).to_i)}"
      end

      true
    end

    # Insert 511 blank spaces in the row to make it easier to read
    # The output string is 511 characters long
    def insert_blank_spaces(row)
      row + ' ' * (511 - row.length)
    end

    def insert_zeros(integer)
      string = integer.to_s
      ("0" * (13 - string.length)  ) + string
    end

    def rendimentos_isentos
      ri = @rows.filter { |row| row.include?(DIVIDENDOS) }
      ri.map do |row|
        {
          type: row[27..28] == '09' ? 'Dividendos' : 'Outros',
          cnpj: row[30..42],
          name: row[43..102],
          value: row[104..117].to_f / 10000.0,
        }
      end
    end
  end
end
