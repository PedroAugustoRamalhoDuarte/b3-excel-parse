# frozen_string_literal: true

require 'dry/cli'
require 'terminal-table'
require './lib/parse'
require './lib/utils'

module B3ExcelParse
  module CLI
    module Commands
      extend Dry::CLI::Registry

      class Version < Dry::CLI::Command
        desc 'Print version'

        def call(*)
          puts '0.1'
        end
      end

      class ListProducts < Dry::CLI::Command
        desc 'List product info'

        argument :excel_file_path, required: true, desc: 'Excel file path from b3'

        def call(excel_file_path:, **)
          parse = Parse.new(excel_file_path)
          puts parse.all_products
        end
      end

      class ProductInfo < Dry::CLI::Command
        include B3ExcelParse::Utils
        desc 'Product Info for IRPF'

        argument :excel_file_path, required: true, desc: 'Excel file path from b3'
        argument :product_name, required: true, desc: 'Excel file path from b3'

        def call(excel_file_path:, product_name:, **)
          parse = Parse.new(excel_file_path)
          transactions = parse.product_transactions(product_name)
          amount, avg_price, total_price = parse.product_info(product_name)
          puts Terminal::Table.new(rows: transactions.map { |k| k.map { |_, y| y } })
          puts "Ativo: #{product_name}"
          puts "Quantidade: #{amount}"
          puts "Preço médio de compra do ativo: #{format_price(avg_price)}"
          puts "Preço total investido: #{format_price(total_price)}"
        end
      end

      class Yield < Dry::CLI::Command
        include B3ExcelParse::Utils

        desc 'Yield for JCP or Dividens'

        argument :excel_file_path, required: true, desc: 'Excel file path from b3'

        def call(excel_file_path:, **)
          parse = Parse.new(excel_file_path)
          rows = parse.all_products.map do |product_name|
            dividens, jscps = parse.product_yield(product_name)
            dividend_sum = dividens.sum { |d| d['Valor da Operação'] }
            jscp_sum = jscps.sum { |d| d['Valor da Operação'] }
            if dividend_sum.positive? || jscp_sum.positive?
              [product_name, format_price(dividend_sum),
               format_price(jscp_sum)]
            end
          end
          puts Terminal::Table.new(title: 'Rendimentos por Ativo', headings: %w[Ativo Dividendo JCP],
                                   rows: rows.compact)
        end
      end

      class IRPF < Dry::CLI::Command
        include B3ExcelParse::Utils
        WARN_EMOJI = "\u{26A0}"

        desc 'Product Info for IRPF'

        argument :excel_file_path, required: true, desc: 'Excel file path from b3'

        def call(excel_file_path:, **)
          parse = Parse.new(excel_file_path)
          rows = parse.all_products.map do |product_name|
            amount, total_price, avg_price = parse.product_info(product_name)
            warning = parse.product_warning?(parse.product_transactions(product_name))
            product_name += " #{WARN_EMOJI}" if warning
            [product_name, amount, format_price(total_price), format_price(avg_price)] if amount.positive?
          end
          puts Terminal::Table.new(title: 'IRPF', rows: rows.compact,
                                   headings: ['Ativo', 'Quantidade', 'Preço Médio de Compra', 'Valor'])
        end
      end

      register 'version', Version, aliases: %w[v -v --version]
      register 'list-products', ListProducts
      register 'product-info', ProductInfo
      register 'irpf', IRPF
      register 'yield', Yield
    end
  end
end

Dry::CLI.new(B3ExcelParse::CLI::Commands).call
