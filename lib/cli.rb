# frozen_string_literal: true

require 'dry/cli'
require 'terminal-table'
require './lib/parse'

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
        desc 'Product Info for IRPF'

        argument :excel_file_path, required: true, desc: 'Excel file path from b3'
        argument :product_name, required: true, desc: 'Excel file path from b3'

        def call(excel_file_path:, product_name:, **)
          parse = Parse.new(excel_file_path)
          transactions = parse.product_transactions(product_name)
          amount, total_price, avg_price = parse.product_info(product_name)
          puts Terminal::Table.new(rows: transactions.map { |k| k.map { |_, y| y } })
          puts "Ativo: #{product_name}"
          puts "Quantidade: #{amount}"
          puts "Preço Total Investido: #{total_price}"
          puts "Preço médio: #{avg_price}"
        end
      end

      class Yield < Dry::CLI::Command
        desc 'Yield for JCP or Dividens'

        argument :excel_file_path, required: true, desc: 'Excel file path from b3'

        def call(excel_file_path:, **)
          parse = Parse.new(excel_file_path)
          rows = parse.all_products.map do |product_name|
            dividens, jscps = parse.product_yield(product_name)
            dividend_sum = dividens.sum { |d| d['Valor da Operação'] }
            jscp_sum = jscps.sum { |d| d['Valor da Operação'] }
            [product_name, dividend_sum, jscp_sum] if dividend_sum.positive? || jscp_sum.positive?
          end
          puts Terminal::Table.new(title: 'Rendimentos por Ativo', headings: %w[Ativo Dividendo JCP], rows: rows.compact)
        end
      end

      class IRPF < Dry::CLI::Command
        desc 'Product Info for IRPF'

        argument :excel_file_path, required: true, desc: 'Excel file path from b3'

        def call(excel_file_path:, **)
          parse = Parse.new(excel_file_path)
          rows = parse.all_products.map do |product_name|
            amount, total_price, avg_price = parse.product_info(product_name)
            [product_name, amount, total_price, avg_price] if amount.positive?
          end
          rows = rows.compact
          puts Terminal::Table.new(rows:)
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
