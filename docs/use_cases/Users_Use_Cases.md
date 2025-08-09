# **Documentação de Casos de Uso – API DummyJSON Users ([dummyjson.com/users](https://dummyjson.com/users))**
Api described on: `https://dummyjson.com/docs/users`
---
### **Caso de Uso 1: Login de Usuário**

* **ID:** UC-USER-001
* **Título:** Autenticar usuário com credenciais válidas.
* **Descrição:** Este caso de uso descreve o processo de um cliente da API se autenticando no sistema ao fornecer um nome de usuário (`username`) e senha (`password`) válidos para obter tokens de acesso.
* **Atores:** Cliente da API.
* **Pré-condições:** O cliente deve possuir um `username` e `password` válidos de um usuário existente na base de dados.
* **Fluxo de Eventos (Cenário de Sucesso):**
    1.  O cliente da API envia uma requisição `POST` para o endpoint `https://dummyjson.com/auth/login`.
    2.  O corpo da requisição contém o `username` e o `password` do usuário em formato JSON.
    3.  O sistema valida as credenciais fornecidas.
    4.  O sistema gera um token de acesso (`token`).
    5.  O sistema retorna uma resposta `200 OK` com os dados básicos do usuário e o `token` no corpo da resposta.
* **Pós-condições:**
    * O cliente da API está apto a realizar requisições autenticadas.
    * O cliente da API recebe e pode armazenar o token de acesso para uso em requisições futuras.
* **Fluxos Alternativos (Exceções e Erros):**
    * **UC-001-E1 (Credenciais Inválidas):**
        1.  Se o cliente fornecer um `username` ou `password` incorreto.
        2.  O sistema retorna uma resposta de erro `400 Bad Request` com a mensagem "Invalid credentials".

---

### **Caso de Uso 2: Consultar Todos os Usuários**

* **ID:** UC-USER-002
* **Título:** Obter a lista completa de usuários.
* **Descrição:** Descreve a obtenção de uma lista paginada de todos os usuários disponíveis na API.
* **Atores:** Cliente da API.
* **Pré-condições:** A API deve estar acessível.
* **Fluxo de Eventos (Cenário de Sucesso):**
    1.  O cliente da API envia uma requisição `GET` para o endpoint `https://dummyjson.com/users`.
    2.  O sistema processa a requisição.
    3.  O sistema retorna uma resposta `200 OK`.
    4.  O corpo da resposta contém um objeto JSON com uma chave `users` (contendo uma lista de usuários) e chaves de paginação (`total`, `skip`, `limit`).
* **Pós-condições:**
    * O cliente da API recebe a primeira página de usuários com sucesso.
* **Fluxos Alternativos (Exceções e Erros):**
    * **UC-USER-002-A1 (Paginação e Limite de Resultados):**
        1.  O cliente pode adicionar os parâmetros `limit` e `skip` na URL da requisição `GET` (ex: `?limit=10&skip=20`).
        2.  O sistema retorna a lista de usuários de acordo com os parâmetros de paginação especificados.
    * **UC-USER-002-A2 (Ordenação de Resultados):**
        1. O cliente pode adicionar os parâmetros `sortBy` (campo para ordenar) e `order` (`asc` ou `desc`) na URL.
        2. O sistema retorna a lista de usuários ordenada conforme solicitado.

---

### **Caso de Uso 3: Consultar Usuário por ID**

* **ID:** UC-USER-003
* **Título:** Obter os dados de um usuário específico.
* **Descrição:** Este caso de uso descreve como obter as informações detalhadas de um único usuário através de seu identificador (`ID`).
* **Atores:** Cliente da API.
* **Pré-condições:** O `ID` do usuário a ser consultado deve ser válido e existir no sistema.
* **Fluxo de Eventos (Cenário de Sucesso):**
    1.  O cliente da API envia uma requisição `GET` para `https://dummyjson.com/users/{userId}`, onde `{userId}` é o número de identificação.
    2.  O sistema busca o usuário correspondente ao `ID` fornecido.
    3.  O sistema retorna uma resposta `200 OK` com o objeto JSON contendo todos os dados do usuário.
* **Pós-condições:**
    * O cliente da API recebe os detalhes completos do usuário solicitado.
* **Fluxos Alternativos (Exceções e Erros):**
    * **UC-USER-006-E1 (Usuário Não Encontrado):**
        1.  Se o `{userId}` fornecido não corresponder a nenhum usuário na base de dados.
        2.  O sistema retorna uma resposta de erro `404 Not Found` com a mensagem "User not found".

---

### **Caso de Uso 4: Pesquisar Usuários**

* **ID:** UC-USER-004
* **Título:** Realizar uma busca por usuários.
* **Descrição:** Descreve a busca por usuários com base em um termo de pesquisa que pode corresponder a diferentes campos de dados do usuário.
* **Atores:** Cliente da API.
* **Pré-condições:** A API deve estar acessível.
* **Fluxo de Eventos (Cenário de Sucesso):**
    1.  O cliente da API envia uma requisição `GET` para o endpoint `https://dummyjson.com/users/search`.
    2.  A requisição inclui um parâmetro de consulta `q` com o termo a ser pesquisado (ex: `?q=John`).
    3.  O sistema busca o termo em campos relevantes dos registros de usuário.
    4.  O sistema retorna uma resposta `200 OK` com a lista de usuários que correspondem ao critério de busca.
* **Pós-condições:**
    * O cliente recebe uma lista de usuários cujo conteúdo corresponde ao termo pesquisado.

---

### **Caso de Uso 5: Adicionar Novo Usuário (Simulado)**

* **ID:** UC-USER-005
* **Título:** Adicionar um novo usuário ao sistema (simulação).
* **Descrição:** Descreve o processo de enviar dados para criar um novo usuário. A API simula a criação, retornando o objeto criado, mas sem persistir os dados no servidor.
* **Atores:** Cliente da API.
* **Pré-condições:** O cliente deve possuir os dados do novo usuário (ex: `firstName`, `age`) em formato JSON.
* **Fluxo de Eventos (Cenário de Sucesso):**
    1.  O cliente da API envia uma requisição `POST` para `https://dummyjson.com/users/add`.
    2.  O corpo da requisição contém um objeto JSON com os dados do usuário. O cabeçalho `Content-Type` deve ser `application/json`.
    3.  O sistema processa os dados recebidos.
    4.  O sistema retorna uma resposta `200 OK`. O corpo da resposta contém o objeto JSON do usuário enviado, agora incluindo um `ID` gerado pelo sistema.
* **Pós-condições:**
    * O cliente recebe uma resposta confirmando que o usuário foi "criado", juntamente com seu novo ID.

---

### **Caso de Uso 6: Atualizar Usuário (Simulado)**

* **ID:** UC-USER-006
* **Título:** Atualizar os dados de um usuário existente (simulação).
* **Descrição:** Descreve a atualização dos dados de um usuário. A API simula a operação, retornando o objeto modificado, sem persistir a alteração.
* **Atores:** Cliente da API.
* **Pré-condições:** O `ID` do usuário a ser atualizado deve ser conhecido.
* **Fluxo de Eventos (Cenário de Sucesso):**
    1.  O cliente da API envia uma requisição `PUT` ou `PATCH` para `https://dummyjson.com/users/{userId}`.
    2.  O corpo da requisição contém um objeto JSON com os campos e os novos valores a serem atualizados.
    3.  O sistema processa a requisição.
    4.  O sistema retorna uma resposta `200 OK` com o objeto completo do usuário contendo os dados "atualizados".
* **Pós-condições:**
    * O cliente recebe uma resposta com os dados do usuário como se tivessem sido atualizados.
* **Fluxos Alternativos (Exceções e Erros):**
    * **UC-USER-006-E1 (Usuário Não Encontrado):**
        1.  Se o `{userId}` fornecido na URL não existir.
        2.  O sistema retorna uma resposta de erro `404 Not Found` com a mensagem "User not found".

---

### **Caso de Uso 7: Deletar Usuário (Simulado)**

* **ID:** UC-USER-007
* **Título:** Deletar um usuário do sistema (simulação).
* **Descrição:** Descreve a remoção de um usuário. A API simula a exclusão, retornando o objeto do usuário deletado com um status indicando a remoção.
* **Atores:** Cliente da API.
* **Pré-condições:** O `ID` do usuário a ser deletado deve ser conhecido.
* **Fluxo de Eventos (Cenário de Sucesso):**
    1.  O cliente da API envia uma requisição `DELETE` para `https://dummyjson.com/users/{userId}`.
    2.  O sistema processa a requisição de exclusão.
    3.  O sistema retorna uma resposta `200 OK`.
    4.  O corpo da resposta contém o objeto do usuário que foi "removido", acrescido dos campos `isDeleted: true` e `deletedOn`.
* **Pós-condições:**
    * O cliente recebe uma confirmação de que o usuário foi "deletado".
* **Fluxos Alternativos (Exceções e Erros):**
    * **UC-USER-010-E1 (Usuário Não Encontrado):**
        1.  Se o `{userId}` na URL não existir.
        2.  O sistema retorna uma resposta de erro `404 Not Found` com a mensagem "User not found".