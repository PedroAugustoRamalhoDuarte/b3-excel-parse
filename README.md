# B3 Excel Parse

CLI para o parse de informações para o excel da B3

# Atenção
- O código ainda não lida com cisão, fração, subscrição, leilão, reembolso de ativos então o valor em alguns produtos pode divergir do esperado

# Objetivos
- Auxiliar no prenchimento de informações do Imposto de Renda
- Verificar preço médio de ativos

# Como usar?

- Baixe as movimentações realizadas no site da b3 do ano que deseja analisar
- Instale as dependências do ruby `bundle install`
- Utilize os comandos da CLI `ruby lib/cli.rb` para te auxiliar no imposto de renda