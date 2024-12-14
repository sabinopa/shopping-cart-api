# 🛒 Desafio Técnico - Backend: API de Carrinho de Compras

Olá equipe RD, queria agradecer a oportunidade de realizar esse challenge e de poder compartilhar um pouco do meu trabalho com vocês. Eu aprendi muito nesse processo, e espero que a solução que desenvolvi esteja alinhada com o que vocês esperavam. Fico à disposição para qualquer dúvida ou sugestão. :)

## Descrição
![Static Badge](https://img.shields.io/badge/Ruby_3.3.1-CC342D?style=for-the-badge&logo=ruby&logoColor=white)
![Static Badge](https://img.shields.io/badge/Ruby_on_Rails_7.1.3-CC0000?style=for-the-badge&logo=ruby-on-rails&logoColor=white)
![Static Badge](https://img.shields.io/badge/Sidekiq-B1003E.svg?style=for-the-badge&logo=Sidekiq&logoColor=white)
![Static Badge](https://img.shields.io/badge/Docker-2496ED.svg?style=for-the-badge&logo=Docker&logoColor=white)
![Static Badge](https://img.shields.io/badge/PostgreSQL-4169E1.svg?style=for-the-badge&logo=PostgreSQL&logoColor=white)

Este projeto é uma solução para o desafio técnico proposto pela RD Station, focado no desenvolvimento de uma API para gerenciamento de carrinhos de compras de e-commerce. A aplicação oferece operações essenciais como adicionar produtos, atualizar quantidades, remover itens e gerenciar carrinhos abandonados por meio de jobs agendados.

## Funcionalidades

### Gerenciamento de Carrinho
- [x]  **Adicionar Produto ao Carrinho:** Insere um produto em um carrinho. Caso não exista um carrinho associado, cria um novo.
- [x]  **Visualizar Detalhes do Carrinho:** Retorna detalhes do carrinho atual, incluindo informações dos produtos e preço total
- [x]  **Alterar Quantidade de Produtos:** Atualiza a quantidade de um produto já existente no carrinho.
- [x]  **Remover Produto do Carrinho:** Remove um produto do carrinho. Caso o carrinho fique vazio, ele também pode ser finalizado.
### Gerenciamento de Carrinhos Abandonados
- [x]  **Marcar como Abandonado:** Marca carrinhos como abandonados após 3 horas sem interação.
- [x]  **Excluir Carrinhos Abandonados:** Remove carrinhos que ficaram abandonados por mais de 7 dias.
- [x]  **Job Automatizado:** Configuração de um job em background com Sidekiq para gerenciar carrinhos abandonados automaticamente.

## Pré-requisitos

Para rodar este projeto, certifique-se de ter instalados:

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)

## Configuração do Projeto

- Clone este repositório:
```
git clone https://github.com/sabinopa/shopping-cart-api.git
```

- Construa e inicie os containers:
```
docker compose up --build
```
- O servidor será iniciado em http://localhost:3000.

- O painel do Sidekiq pode ser acessado em http://localhost:3000/sidekiq.

### Como executar os testes

- Certifique-se de que os containers estão ativos:
```
docker compose up
```

- Execute os testes:
```
docker compose run test
```
## Endpoints Disponíveis

### Adicionar Produto ao Carrinho

- ```POST /cart```
- Corpo da requisição:
```
{
  "product_id": 1,
  "quantity": 2
}
```
- Resposta:
```
{
  "id": 123,
  "products": [
    {
      "id": 1,
      "name": "Produto Exemplo",
      "quantity": 2,
      "unit_price": 10.0,
      "total_price": 20.0
    }
  ],
  "total_price": 20.0
}
```

### Visualizar Carrinho
- ```GET /cart```
- Resposta:
```
{
  "id": 123,
  "products": [
    {
      "id": 1,
      "name": "Produto Exemplo",
      "quantity": 2,
      "unit_price": 10.0,
      "total_price": 20.0
    }
  ],
  "total_price": 20.0
}
```

### Atualizar Quantidade de Produtos
- ```PATCH /cart/add_item```
- Corpo da requisição:
```
{
  "product_id": 1,
  "quantity": 3
}
```
- Resposta:
```
{
  "id": 123,
  "products": [
    {
      "id": 1,
      "name": "Produto Exemplo",
      "quantity": 5,
      "unit_price": 10.0,
      "total_price": 50.0
    }
  ],
  "total_price": 50.0
}
```

### Remover Produtos do Carrinho
- ```DELETE /cart/:product_id```
- Resposta:
```
{
  "id": 123,
  "products": [],
  "total_price": 0.0
}
```

## Backgroud Jobs

- [x]  **Marcação de Carrinhos Abandonados:** Job que verifica a inatividade de 3 horas e marca o carrinho como abandonado.
- [x]  **Exclusão de Carrinhos Abandonados:** Job que remove carrinhos marcados como abandonados por mais de 7 dias.

- Para iniciar o Sidekiq no ambiente Docker:
```
docker compose exec worker bundle exec sidekiq
```



