# **Documentação de Casos de Uso - API de Autenticação ([dummyjson.com/auth](https://dummyjson.com/auth))**
Api described on: `https://dummyjson.com/docs/auth`
---

#### **Visão Geral**

A API de autenticação do DummyJSON fornece um conjunto de endpoints para gerenciar a autenticação e autorização de usuários. Ela permite que os usuários façam login, obtenham informações do usuário autenticado e atualizem suas sessões de autenticação.

---

### **Caso de Uso 1: Login de Usuário**

* **ID:** UC-AUTH-001
* **Título:** Realizar login com credenciais válidas.
* **Descrição:** Este caso de uso descreve o processo de um usuário se autenticando no sistema fornecendo um nome de usuário e senha válidos.
* **Atores:** Usuário (aplicação cliente).
* **Pré-condições:** O usuário deve possuir um nome de usuário e senha válidos.
* **Fluxo de Eventos (Cenário de Sucesso):**
    1.  A aplicação cliente envia uma requisição `POST` para o endpoint `https://dummyjson.com/auth/login`.
    2.  O corpo da requisição contém o `username` e `password` do usuário em formato JSON.
    3.  O sistema valida as credenciais do usuário.
    4.  O sistema gera um token de acesso (`accessToken`) e um token de atualização (`refreshToken`).
    5.  O sistema retorna uma resposta `200 OK` com os tokens e as informações do usuário no corpo da resposta. Os tokens também são definidos como cookies.
* **Pós-condições:**
    * O usuário está autenticado no sistema.
    * A aplicação cliente recebe e armazena os tokens de acesso e atualização.
* **Fluxos Alternativos (Exceções e Erros):**
    * **UC-AUTH-001-E1 (Credenciais Inválidas):**
        1.  Se o usuário fornecer um `username` ou `password` incorreto.
        2.  O sistema retorna uma resposta de erro `400 Bad Request` com a mensagem "Invalid credentials".

---

### **Caso de Uso 2: Obter Usuário Autenticado**

* **ID:** UC-AUTH-002
* **Título:** Obter informações do usuário atualmente autenticado.
* **Descrição:** Este caso de uso descreve como uma aplicação cliente pode obter as informações do usuário que está atualmente logado.
* **Atores:** Usuário (aplicação cliente).
* **Pré-condições:**
    * O usuário deve estar autenticado.
    * A aplicação cliente deve possuir um `accessToken` válido.
* **Fluxo de Eventos (Cenário de Sucesso):**
    1.  A aplicação cliente envia uma requisição `GET` para o endpoint `https://dummyjson.com/auth/me`.
    2.  A requisição inclui o `accessToken` no cabeçalho `Authorization` como um token Bearer (`Authorization: Bearer <token>`).
    3.  O sistema valida o `accessToken`.
    4.  O sistema retorna uma resposta `200 OK` com as informações do usuário autenticado.
* **Pós-condições:** A aplicação cliente recebe e pode exibir as informações do usuário.
* **Fluxos Alternativos (Exceções e Erros):**
    * **UC-AUTH-002-E1 (Token Inválido ou Expirado):**
        1.  Se o `accessToken` fornecido for inválido ou estiver expirado.
        2.  O sistema retorna uma resposta de erro `401 Unauthorized` ou `403 Forbidden` indicando que o token é inválido.

---

### **Caso de Uso 3: Atualizar Sessão de Autenticação**

* **ID:** UC-AUTH-003
* **Título:** Atualizar o token de acesso usando o token de atualização.
* **Descrição:** Este caso de uso descreve o processo de obtenção de um novo `accessToken` sem a necessidade de o usuário inserir novamente suas credenciais, utilizando o `refreshToken`.
* **Atores:** Usuário (aplicação cliente).
* **Pré-condições:**
    * O usuário deve ter se autenticado previamente e possuir um `refreshToken` válido.
* **Fluxo de Eventos (Cenário de Sucesso):**
    1.  A aplicação cliente envia uma requisição `POST` para o endpoint `https://dummyjson.com/auth/refresh`.
    2.  O corpo da requisição contém o `refreshToken` válido.
    3.  O sistema valida o `refreshToken`.
    4.  O sistema gera um novo `accessToken` e um novo `refreshToken`.
    5.  O sistema retorna uma resposta `200 OK` com os novos tokens no corpo da resposta e também os define como cookies.
* **Pós-condições:**
    * A sessão do usuário é estendida.
    * A aplicação cliente recebe e armazena os novos `accessToken` e `refreshToken`.
* **Fluxos Alternativos (Exceções e Erros):**
    * **UC-AUTH-003-E1 (Token de Atualização Inválido):**
        1.  Se o `refreshToken` fornecido for inválido ou expirado.
        2.  O sistema retorna uma resposta de erro `401 Unauthorized` ou `403 Forbidden`, indicando que o `refreshToken` é inválido. O usuário precisará fazer login novamente (UC-001).