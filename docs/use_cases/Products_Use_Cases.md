# **Documentação de Casos de Uso – API DummyJSON Products ([dummyjson.com/products](https://dummyjson.com/products))**
Api described on: `https://dummyjson.com/docs/products`
---

### **Caso de Uso 1: Consultar Lista de Produtos**

* **ID:** UC-PROD-001
* **Título:** Obter a lista completa de produtos.
* **Descrição:** Este caso de uso descreve como uma aplicação cliente solicita a lista de todos os produtos disponíveis, suportando paginação.
* **Atores:** Aplicação Cliente, Desenvolvedor.
* **Pré-condições:** A aplicação cliente precisa ter acesso ao endpoint da API.
* **Fluxo de Eventos (Cenário de Sucesso):**
    1.  A aplicação cliente envia uma requisição `GET` para o endpoint `https://dummyjson.com/products`.
    2.  O sistema processa a requisição para buscar a lista de produtos.
    3.  O sistema retorna uma resposta `200 OK`.
    4.  O corpo da resposta contém um objeto JSON com a lista de produtos (`products`), o total de itens (`total`), o número de itens a pular (`skip`) e o limite (`limit`).
* **Pós-condições:**
    * A lista de produtos é retornada com sucesso para a aplicação cliente.
* **Fluxos Alternativos (Exceções e Erros):**
    * **UC-PROD-001 (Paginação Customizada):**
        1.  A aplicação cliente envia a requisição `GET` com os parâmetros de consulta `limit` e `skip` (ex: `.../products?limit=10&skip=20`).
        2.  O sistema retorna a lista de produtos de acordo com os parâmetros de paginação especificados.

---

### **Caso de Uso 2: Consultar Produto por ID**

* **ID:** UC-PROD-002
* **Título:** Obter os detalhes de um produto específico.
* **Descrição:** Este caso de uso descreve o processo de obtenção dos detalhes completos de um único produto através do seu ID.
* **Atores:** Aplicação Cliente, Desenvolvedor.
* **Pré-condições:** O cliente deve conhecer o ID do produto que deseja consultar.
* **Fluxo de Eventos (Cenário de Sucesso):**
    1.  A aplicação cliente envia uma requisição `GET` para o endpoint `https://dummyjson.com/products/{id}` (ex: `.../products/1`).
    2.  O sistema valida a existência do produto com o ID fornecido.
    3.  O sistema retorna uma resposta `200 OK` com o objeto JSON contendo os detalhes do produto no corpo da resposta.
* **Pós-condições:**
    * Os detalhes do produto solicitado são retornados para a aplicação cliente.
* **Fluxos Alternativos (Exceções e Erros):**
    * **UC-PROD-002-E1 (Produto Não Encontrado):**
        1.  Se o cliente fornecer um ID que não corresponde a nenhum produto existente.
        2.  O sistema retorna uma resposta de erro `404 Not Found` com a mensagem "Product with id '{id}' not found".

---

### **Caso de Uso 3: Pesquisar Produtos**

* **ID:** UC-PROD-003
* **Título:** Realizar busca de produtos por termo.
* **Descrição:** Este caso de uso descreve como uma aplicação cliente pode pesquisar produtos com base em uma palavra-chave.
* **Atores:** Aplicação Cliente, Desenvolvedor.
* **Pré-condições:** Nenhuma.
* **Fluxo de Eventos (Cenário de Sucesso):**
    1.  A aplicação cliente envia uma requisição `GET` para o endpoint `https://dummyjson.com/products/search`.
    2.  A requisição inclui um parâmetro de consulta `q` com o termo de busca (ex: `.../search?q=phone`).
    3.  O sistema busca por produtos que correspondam ao termo no parâmetro `q`.
    4.  O sistema retorna uma resposta `200 OK` com a lista de produtos encontrados.
* **Pós-condições:**
    * A aplicação cliente recebe a lista de produtos que correspondem à busca.
* **Fluxos Alternativos (Exceções e Erros):**
    * **UC-PROD-004-A1 (Busca Sem Resultados):**
        1.  Se nenhum produto for encontrado para o termo pesquisado.
        2.  O sistema retorna uma resposta `200 OK` com uma lista vazia de produtos (`"products": []`) e `total` igual a 0.

---

### **Caso de Uso 4: Obter Categorias de Produtos**

* **ID:** UC-PROD-004
* **Título:** Consultar a lista de todas as categorias.
* **Descrição:** Descreve o processo para obter uma lista com os nomes de todas as categorias de produtos disponíveis.
* **Atores:** Aplicação Cliente, Desenvolvedor.
* **Pré-condições:** Nenhuma.
* **Fluxo de Eventos (Cenário de Sucesso):**
    1.  A aplicação cliente envia uma requisição `GET` para o endpoint `https://dummyjson.com/products/categories`.
    2.  O sistema processa a requisição.
    3.  O sistema retorna uma resposta `200 OK` com um array de strings, onde cada string é um nome de categoria.
* **Pós-condições:**
    * A aplicação cliente recebe a lista completa de nomes de categorias.
* **Fluxos Alternativos (Exceções e Erros):**
    * Nenhum fluxo alternativo principal identificado na documentação.

---

### **Caso de Uso 5: Obter Produtos por Categoria**

* **ID:** UC-PROD-005
* **Título:** Listar produtos de uma categoria específica.
* **Descrição:** Este caso de uso descreve como obter todos os produtos que pertencem a uma categoria específica.
* **Atores:** Aplicação Cliente, Desenvolvedor.
* **Pré-condições:** O cliente deve conhecer o nome da categoria que deseja filtrar.
* **Fluxo de Eventos (Cenário de Sucesso):**
    1.  A aplicação cliente envia uma requisição `GET` para `https://dummyjson.com/products/category/{categoryName}` (ex: `.../category/smartphones`).
    2.  O sistema busca todos os produtos pertencentes à categoria especificada.
    3.  O sistema retorna uma resposta `200 OK` com a lista de produtos daquela categoria.
* **Pós-condições:**
    * A aplicação cliente recebe a lista de produtos filtrada pela categoria.
* **Fluxos Alternativos (Exceções e Erros):**
    * **UC-PROD-005-A1 (Categoria Inexistente):**
        1.  Se o `categoryName` fornecido não existir.
        2.  O sistema retorna uma resposta `200 OK` com uma lista vazia de produtos.

---

### **Caso de Uso 6: Adicionar Novo Produto**

* **ID:** UC-PROD-006
* **Título:** Cadastrar um novo produto (simulação).
* **Descrição:** Este caso de uso descreve a simulação de adicionar um novo produto ao sistema.
* **Atores:** Aplicação Cliente, Desenvolvedor.
* **Pré-condições:** O cliente deve ter os dados do produto a ser adicionado formatados em JSON.
* **Fluxo de Eventos (Cenário de Sucesso):**
    1.  A aplicação cliente envia uma requisição `POST` para o endpoint `https://dummyjson.com/products/add`.
    2.  O corpo da requisição contém os dados do produto, como `title`, em formato JSON.
    3.  O sistema simula a criação do produto.
    4.  O sistema retorna uma resposta `200 OK` ou `201 Created`.
    5.  O corpo da resposta contém o objeto do produto enviado, acrescido de um novo `id`.
* **Pós-condições:**
    * A aplicação cliente recebe os dados do produto "criado", incluindo seu novo ID.
* **Fluxos Alternativos (Exceções e Erros):**
    * **UC-PROD-006-E1 (Dados Inválidos):**
        1.  Se o corpo da requisição estiver malformatado ou faltando campos essenciais.
        2.  O sistema pode retornar um erro `400 Bad Request`.

---

### **Caso de Uso 17: Atualizar Produto**

* **ID:** UC-PROD-007
* **Título:** Atualizar os dados de um produto existente (simulação).
* **Descrição:** Este caso de uso descreve a simulação de atualizar as informações de um produto existente, identificado por seu ID.
* **Atores:** Aplicação Cliente, Desenvolvedor.
* **Pré-condições:** O cliente deve conhecer o ID do produto e ter os novos dados em formato JSON.
* **Fluxo de Eventos (Cenário de Sucesso):**
    1.  A aplicação cliente envia uma requisição `PUT` ou `PATCH` para `https://dummyjson.com/products/{id}` (ex: `.../products/1`).
    2.  O corpo da requisição contém os campos a serem atualizados (ex: `{ "title": "Novo Título" }`).
    3.  O sistema simula a atualização do produto.
    4.  O sistema retorna uma resposta `200 OK` com o objeto completo do produto contendo os dados atualizados.
* **Pós-condições:**
    * A aplicação cliente recebe os dados completos do produto "atualizado".
* **Fluxos Alternativos (Exceções e Erros):**
    * **UC-PROD-007-E1 (Produto Não Encontrado):**
        1.  Se o cliente fornecer um ID que não corresponde a nenhum produto existente.
        2.  O sistema retorna uma resposta de erro `404 Not Found`.

---

### **Caso de Uso 8: Deletar Produto**

* **ID:** UC-PROD-008
* **Título:** Excluir um produto (simulação).
* **Descrição:** Este caso de uso descreve a simulação de exclusão de um produto existente, identificado por seu ID.
* **Atores:** Aplicação Cliente, Desenvolvedor.
* **Pré-condições:** O cliente deve conhecer o ID do produto a ser deletado.
* **Fluxo de Eventos (Cenário de Sucesso):**
    1.  A aplicação cliente envia uma requisição `DELETE` para o endpoint `https://dummyjson.com/products/{id}` (ex: `.../products/1`).
    2.  O sistema simula a exclusão do produto.
    3.  O sistema retorna uma resposta `200 OK`.
    4.  O corpo da resposta contém o objeto do produto deletado com as chaves adicionais `isDeleted: true` e `deletedOn`.
* **Pós-condições:**
    * O produto é marcado como "deletado" e a confirmação é enviada para a aplicação cliente.
* **Fluxos Alternativos (Exceções e Erros):**
    * **UC-PROD-008-E1 (Produto Não Encontrado):**
        1.  Se o cliente fornecer um ID que não corresponde a nenhum produto existente.
        2.  O sistema retorna uma resposta de erro `404 Not Found`.