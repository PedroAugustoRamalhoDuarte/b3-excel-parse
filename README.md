# B3 Excel Parse

CLI para o parse de informações para o excel da B3

## Atenção

- O código ainda não lida com cisão, fração, subscrição, leilão, reembolso de ativos então o valor em alguns produtos
  pode divergir do esperado.

## Objetivos

- Auxiliar no preenchimento de informações do Imposto de Renda.
- Verificar preço médio de ativos.
- Visualizar os dividendos de cada ativo.

## Como usar?

- Baixe as movimentações realizadas no site da b3 do ano que deseja analisar:
    - Faça login
      no [site da b3](https://www.investidor.b3.com.br/?utm_source=home_b3&utm_medium=botao_area_investidor&utm_campaign=lancamento_area_investidor),
      abra o menu de Extratos, depois clique na aba de Movimentação e filtre as datas 1 de janeiro e 31 de dezembro do
      ano em que deseja declarar, em seguida clique no botão de download no canto inferior direito e exporte para excel.
- Instale as dependências do ruby `bundle install`.
- Utilize os comandos da CLI `ruby lib/cli.rb` para te auxiliar no imposto de renda.

## Disclaimer

Toda a responsabilidade de conferência dos valores e do envio dessas informações à Receita Federal é do usuário, e
possivelmente o valor estará incoerente para alguns dos ativos, pois o código está em desenvolvimento.
