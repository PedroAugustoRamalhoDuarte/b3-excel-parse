require 'dry/cli'
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

        def call(**)
          puts 'Not done yet'
        end
      end

      class ProductInfo < Dry::CLI::Command
        argument :excel_file_path, required: true, desc: 'Excel file path from b3'
        argument :product_name, required: true, desc: 'Excel file path from b3'

        def call(excel_file_path:, product_name:, **)
          parse = Parse.new(excel_file_path)
          parse.product_info(product_name)
        end
      end

      register 'version', Version, aliases: %w[v -v --version]
      register 'list-product', ListProducts
      register 'product-info', ProductInfo
    end
  end
end

Dry::CLI.new(B3ExcelParse::CLI::Commands).call
