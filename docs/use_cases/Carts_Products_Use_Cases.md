# **Documentação de Casos de Uso – Integração Carts + Products (DummyJSON)**
Api described on: `https://dummyjson.com/docs/products` e `https://dummyjson.com/docs/carts`
---

#### Visão Geral

Estes casos de uso integram os domínios Products e Carts do DummyJSON. Os fluxos partem da descoberta/seleção de produtos (Products) e culminam em operações de carrinho (Carts), cobrindo criação, atualização e exclusão. Observação importante: os endpoints de criação/atualização/deleção do DummyJSON são simulados (não persistem no servidor); portanto, fluxos que esperam leitura subsequente devem ser tratados de forma inclusiva.

---

### Caso de Uso 1: Adicionar ao Carrinho um Produto de uma Categoria

* ID: UC-CARTPROD-001
* Título: Selecionar produto por categoria e adicioná-lo ao carrinho.
* Descrição: O cliente lista categorias de produtos, escolhe uma categoria, obtém os produtos dessa categoria e adiciona um item ao carrinho com quantidade desejada.
* Atores: Aplicação Cliente.
* Pré-condições:
  * Categoria existente (ex.: `smartphones`).
  * `userId` válido (qualquer inteiro aceito pela API simulada).
* Fluxo de Eventos (Cenário de Sucesso):
  1. Enviar `GET https://dummyjson.com/products/categories` e validar resposta `200 OK` contendo lista de categorias.
  2. Enviar `GET https://dummyjson.com/products/category/{category}` (ex.: `smartphones`) e validar `200 OK` com lista não vazia.
  3. Selecionar um `product.id` do resultado e construir payload do carrinho: `{ "userId": <id>, "products": [{ "id": <product.id>, "quantity": 1 }] }`.
  4. Enviar `POST https://dummyjson.com/carts/add` com `Content-Type: application/json` e validar `200/201`.
  5. Validar que a resposta contém o item com título/preço coerentes e totais calculados (`total`, `discountedTotal`, `totalProducts`, `totalQuantity`).
* Pós-condições:
  * Carrinho “criado” (simulado) com o produto selecionado.
* Fluxos Alternativos (Exceções e Erros):
  * UC-CARTPROD-001-A1 (Categoria sem produtos): `GET /products/category/{category}` retorna lista vazia; não executar o passo de `POST /carts/add` e encerrar com evidência da ausência.

---

### Caso de Uso 2: Buscar por Termo e Adicionar + Atualizar Quantidade no Carrinho

* ID: UC-CARTPROD-002
* Título: Pesquisar produto, adicionar ao carrinho e atualizar quantidade com merge.
* Descrição: O cliente pesquisa por termo, adiciona um produto retornado ao carrinho e em seguida atualiza o carrinho para ajustar a quantidade, usando `merge=true`.
* Atores: Aplicação Cliente.
* Pré-condições: Termo com resultado (ex.: `phone`).
* Fluxo de Eventos (Cenário de Sucesso):
  1. Enviar `GET https://dummyjson.com/products/search?q={q}` e validar `200 OK` com pelo menos um produto.
  2. Selecionar um `product.id` do resultado e enviar `POST https://dummyjson.com/carts/add` com `{ userId, products: [{ id: <id>, quantity: 1 }] }` validando `200/201`.
  3. Em seguida, atualizar o carrinho retornado via `PUT https://dummyjson.com/carts/{cart.id}` com `{ merge: true, products: [{ id: <id>, quantity: 2 }] }` e validar `200 OK`.
  4. Validar que `total`, `discountedTotal`, `totalProducts` e `totalQuantity` refletem a atualização.
* Pós-condições: Carrinho “atualizado” (simulado) com quantidade ajustada.
* Fluxos Alternativos (Exceções e Erros):
  * UC-CARTPROD-002-A1 (Busca sem resultados): `GET /products/search` retorna `total=0` e `products=[]`; encerrar o fluxo sem adicionar/atualizar carrinho.

---

### Caso de Uso 3: Carrinho com Múltiplos Produtos de Categorias Diferentes

* ID: UC-CARTPROD-003
* Título: Selecionar produtos de duas categorias e criar carrinho combinado.
* Descrição: O cliente obtém produtos de duas categorias distintas e adiciona itens de ambas ao mesmo carrinho, validando agregados.
* Atores: Aplicação Cliente.
* Pré-condições: Duas categorias existentes (ex.: `smartphones` e `laptops`).
* Fluxo de Eventos (Cenário de Sucesso):
  1. `GET /products/category/{catA}` → selecionar um produto A.
  2. `GET /products/category/{catB}` → selecionar um produto B.
  3. `POST /carts/add` com `{ userId, products: [{ id: <A.id>, quantity: 1 }, { id: <B.id>, quantity: 1 }] }` validando `200/201`.
  4. Validar `totalProducts >= 2`, `totalQuantity >= 2` e consistência básica dos preços/totais.
* Pós-condições: Carrinho “criado” (simulado) com múltiplos itens.
* Fluxos Alternativos (Exceções e Erros):
  * UC-CARTPROD-003-A1 (Uma categoria sem itens): montar carrinho apenas com a categoria disponível; validar agregados coerentes.

---

### Caso de Uso 4: Remover Produto via Atualização de Carrinho

* ID: UC-CARTPROD-004
* Título: Atualizar carrinho substituindo conteúdo (merge=false) para simular remoção.
* Descrição: Após criar um carrinho com 2 produtos, atualizar o carrinho sem `merge` para manter apenas 1, simulando remoção do outro.
* Atores: Aplicação Cliente.
* Pré-condições: Carrinho “criado” no fluxo anterior ou por `POST /carts/add`.
* Fluxo de Eventos (Cenário de Sucesso):
  1. Criar carrinho com dois produtos (vide UC-CARTPROD-003, passo 3) ou reaproveitar `cart.id` existente.
  2. `PUT /carts/{cart.id}` com `{ merge: false, products: [{ id: <um_dos_ids>, quantity: 1 }] }` e validar `200 OK`.
  3. Validar que os agregados (`totalProducts`, `totalQuantity`, `total`, `discountedTotal`) foram reduzidos, e que apenas o produto desejado permanece.
* Pós-condições: Carrinho “atualizado” (simulado) contendo somente o item esperado.
* Fluxos Alternativos (Exceções e Erros):
  * UC-CARTPROD-004-E1 (Produto inexistente no update): API pode responder com item não alterado ou erro; validar resposta de forma inclusiva (status `200/4xx`).

---

### Caso de Uso 5: Encerrar Ciclo – Deletar Carrinho após Operações

* ID: UC-CARTPROD-005
* Título: Excluir carrinho após adicionar e ajustar itens.
* Descrição: Após criar e ajustar o carrinho, o cliente solicita a exclusão do carrinho para encerrar o ciclo de teste.
* Atores: Aplicação Cliente.
* Pré-condições: `cart.id` obtido de fluxo anterior.
* Fluxo de Eventos (Cenário de Sucesso):
  1. `DELETE https://dummyjson.com/carts/{cart.id}` e validar `200 OK`.
  2. Validar campos `isDeleted: true` e `deletedOn` presentes na resposta.
* Pós-condições: Carrinho “deletado” (simulado) com indicação explícita no payload.
* Fluxos Alternativos (Exceções e Erros):
  * UC-CARTPROD-005-E1 (Carrinho inexistente): API pode responder `404 Not Found`.

---

### Observações de Integração e Limitações do Fornecedor

- Os endpoints de criação/atualização/deleção são simulados e não persistem dados. Evite dependências entre testes que assumam leitura posterior do que foi “criado/atualizado”.
- Em criações, aceite `200/201` como válidos. Em `/carts/user/{id}`, a API pode responder `200` com lista vazia ou `404` quando não houver recurso; trate asserts de modo inclusivo.
- Totais (`total`, `discountedTotal`) e contagens (`totalProducts`, `totalQuantity`) são calculados pelo provedor com base em `price`, `discountPercentage` e `quantity` dos itens.

