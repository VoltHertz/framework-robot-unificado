# **Documentação de Casos de Uso – API DummyJSON Carts ([dummyjson.com/carts](https://dummyjson.com/carts))**
Api described on: `https://dummyjson.com/docs/carts`
---

### **Caso de Uso 1: Obter Todos os Carrinhos**

* **ID:** UC-CART-01
* **Título:** Obter uma lista de todos os carrinhos.
* **Descrição:** Este caso de uso descreve o processo de obtenção de uma lista paginada de todos os carrinhos disponíveis no sistema.
* **Atores:** Aplicação Cliente.
* **Pré-condições:** Nenhuma pré-condição específica.
* **Fluxo de Eventos (Cenário de Sucesso):**
    1.  A aplicação cliente envia uma requisição `GET` para o endpoint `https://dummyjson.com/carts`.
    2.  O sistema recupera a lista de todos os carrinhos.
    3.  O sistema retorna uma resposta `200 OK` com um objeto JSON contendo uma lista de carrinhos (`carts`), o número total de carrinhos (`total`), o número de carrinhos a serem ignorados (`skip`) e o limite de carrinhos por página (`limit`).
* **Pós-condições:**
    * A aplicação cliente recebe a lista de carrinhos.
* **Fluxos Alternativos (Exceções e Erros):**
    * **UC-CART-001-A1 (Uso de `limit` e `skip`):**
        1.  A aplicação cliente pode adicionar os parâmetros de consulta `limit` e `skip` para paginar os resultados. Por exemplo: `https://dummyjson.com/carts?limit=10&skip=10`.
        2.  O sistema retorna a lista de carrinhos de acordo com os parâmetros de paginação.

---

### **Caso de Uso 2: Obter um Único Carrinho**

* **ID:** UC-CART-002
* **Título:** Obter os detalhes de um carrinho específico.
* **Descrição:** Este caso de uso descreve o processo de obtenção dos detalhes completos de um único carrinho usando seu ID.
* **Atores:** Aplicação Cliente.
* **Pré-condições:** O ID do carrinho a ser consultado deve existir no sistema.
* **Fluxo de Eventos (Cenário de Sucesso):**
    1.  A aplicação cliente envia uma requisição `GET` para o endpoint `https://dummyjson.com/carts/{id}`, onde `{id}` é o ID do carrinho desejado (por exemplo, `1`).
    2.  O sistema busca o carrinho com o ID fornecido.
    3.  O sistema retorna uma resposta `200 OK` com um objeto JSON contendo os detalhes do carrinho.
* **Pós-condições:**
    * A aplicação cliente recebe os detalhes do carrinho solicitado.
* **Fluxos Alternativos (Exceções e Erros):**
    * **UC-CART-002-E1 (Carrinho Não Encontrado):**
        1.  Se o `id` fornecido não corresponder a nenhum carrinho existente.
        2.  O sistema retorna uma resposta de erro `404 Not Found` com a mensagem "Cart with id '{id}' not found".

---

### **Caso de Uso 3: Obter Carrinhos de um Usuário**

* **ID:** UC-CART-003
* **Título:** Obter todos os carrinhos de um usuário específico.
* **Descrição:** Este caso de uso descreve o processo de obtenção de todos os carrinhos associados a um ID de usuário específico.
* **Atores:** Aplicação Cliente.
* **Pré-condições:** O ID do usuário deve existir no sistema.
* **Fluxo de Eventos (Cenário de Sucesso):**
    1.  A aplicação cliente envia uma requisição `GET` para o endpoint `https://dummyjson.com/carts/user/{userId}`, onde `{userId}` é o ID do usuário (por exemplo, `5`).
    2.  O sistema busca todos os carrinhos associados ao `userId` fornecido.
    3.  O sistema retorna uma resposta `200 OK` com um objeto JSON contendo a lista de carrinhos do usuário.
* **Pós-condições:**
    * A aplicação cliente recebe a lista de carrinhos do usuário especificado.
* **Fluxos Alternativos (Exceções e Erros):**
    * **UC-CART-003-E1 (Usuário Sem Carrinhos ou Inexistente):**
        1.  Se o `userId` fornecido não existir ou não tiver carrinhos associados.
        2.  O sistema retorna uma resposta `200 OK` com uma lista vazia de carrinhos.

---

### **Caso de Uso 4: Adicionar um Novo Carrinho**

* **ID:** UC-CART-004
* **Título:** Adicionar um novo carrinho ao sistema.
* **Descrição:** Este caso de uso descreve a simulação da criação de um novo carrinho com produtos para um usuário específico. A adição não é persistida no servidor.
* **Atores:** Aplicação Cliente.
* **Pré-condições:** O ID do usuário e os IDs dos produtos a serem adicionados devem ser válidos.
* **Fluxo de Eventos (Cenário de Sucesso):**
    1.  A aplicação cliente envia uma requisição `POST` para o endpoint `https://dummyjson.com/carts/add`.
    2.  O corpo da requisição contém um objeto JSON com o `userId` e uma lista de `products` (cada um com `id` e `quantity`).
    3.  O sistema simula a criação do novo carrinho.
    4.  O sistema retorna uma resposta `200 OK` com o objeto JSON do carrinho recém-criado, incluindo um novo `id` de carrinho.
* **Pós-condições:**
    * A aplicação cliente recebe a representação do carrinho que foi "adicionado".
* **Fluxos Alternativos (Exceções e Erros):**
    * **UC-CART-004-E1 (Corpo da Requisição Inválido):**
        1.  Se o corpo da requisição estiver malformado ou faltando campos obrigatórios.
        2.  O sistema pode retornar uma resposta de erro `400 Bad Request`.

---

### **Caso de Uso 5: Atualizar um Carrinho**

* **ID:** UC-CART-005
* **Título:** Atualizar os produtos de um carrinho existente.
* **Descrição:** Este caso de uso descreve a simulação da atualização de um carrinho existente, adicionando ou modificando produtos. A atualização não é persistida no servidor.
* **Atores:** Aplicação Cliente.
* **Pré-condições:** O ID do carrinho a ser atualizado deve existir.
* **Fluxo de Eventos (Cenário de Sucesso):**
    1.  A aplicação cliente envia uma requisição `PUT` ou `PATCH` para o endpoint `https://dummyjson.com/carts/{id}`, onde `{id}` é o ID do carrinho.
    2.  O corpo da requisição contém um objeto JSON com uma lista de `products` a serem adicionados/atualizados. Para mesclar com os produtos existentes em vez de substituí-los, o corpo deve incluir `"merge": true`.
    3.  O sistema simula a atualização do carrinho.
    4.  O sistema retorna uma resposta `200 OK` com o objeto JSON do carrinho atualizado.
* **Pós-condições:**
    * A aplicação cliente recebe a representação do carrinho que foi "atualizado".
* **Fluxos Alternativos (Exceções e Erros):**
    * **UC-CART-005-E1 (Carrinho Não Encontrado):**
        1.  Se o `id` fornecido não corresponder a nenhum carrinho existente.
        2.  O sistema retorna uma resposta de erro `404 Not Found` com a mensagem "Cart with id '{id}' not found".
    * **UC-CART-005-E2 (Corpo da Requisição Inválido):**
        1.  Se o corpo da requisição estiver malformado.
        2.  O sistema pode retornar uma resposta de erro `400 Bad Request`.

---

### **Caso de Uso 6: Deletar um Carrinho**

* **ID:** UC-CART-006
* **Título:** Deletar um carrinho existente.
* **Descrição:** Este caso de uso descreve a simulação da exclusão de um carrinho existente. A exclusão não é persistida no servidor, mas o objeto retornado indica que a exclusão ocorreu.
* **Atores:** Aplicação Cliente.
* **Pré-condições:** O ID do carrinho a ser deletado deve existir.
* **Fluxo de Eventos (Cenário de Sucesso):**
    1.  A aplicação cliente envia uma requisição `DELETE` para o endpoint `https://dummyjson.com/carts/{id}`, onde `{id}` é o ID do carrinho.
    2.  O sistema simula a exclusão do carrinho.
    3.  O sistema retorna uma resposta `200 OK` com o objeto JSON do carrinho que foi "deletado", agora contendo as chaves `isDeleted: true` e `deletedOn` (com a data e hora da exclusão).
* **Pós-condições:**
    * A aplicação cliente recebe a representação do carrinho que foi "deletado".
* **Fluxos Alternativos (Exceções e Erros):**
    * **UC-CART-006-E1 (Carrinho Não Encontrado):**
        1.  Se o `id` fornecido não corresponder a nenhum carrinho existente.
        2.  O sistema retorna uma resposta de erro `404 Not Found` com a mensagem "Cart with id '{id}' not found".