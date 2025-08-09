# **Documentação de Casos de Uso – API DummyJSON Posts ([dummyjson.com/posts](https://dummyjson.com/posts))**
Api descrita em: `https://dummyjson.com/docs/posts`
---

### **Caso de Uso 1: Listar Todos os Posts (Paginação Padrão)**
* **ID:** UC-POST-001
* **Título:** Obter lista paginada de posts.
* **Descrição:** Recupera todos os posts usando paginação default (`limit=30`, `skip=0`).
* **Atores:** Aplicação Cliente.
* **Pré-condições:** Nenhuma.
* **Fluxo (Sucesso):**
  1. Enviar `GET https://dummyjson.com/posts`.
  2. Sistema retorna `200 OK` com objeto contendo `posts`, `total`, `skip`, `limit`.
* **Pós-condição:** Lista de posts recebida.
* **Fluxos Alternativos / Variações:**
  * UC-POST-001-A1: Paginação customizada `GET /posts?limit=5&skip=10` retorna subconjunto esperado.
  * UC-POST-001-A2: `limit=0` deve retornar todos os itens (validar tamanho == total).
  * UC-POST-001-A3: Parâmetros de ordenação `GET /posts?sort=title&order=asc` (quando suportado) retornam coleção ordenada.
* **Exceções / Erros:**
  * UC-POST-001-E1: `limit` negativo ou não numérico → validar resposta (documentar comportamento real observado futuramente).

---

### **Caso de Uso 2: Obter Post por ID**
* **ID:** UC-POST-002
* **Título:** Obter um post específico.
* **Descrição:** Recupera detalhes completos de um post existente.
* **Pré-condições:** ID válido existente.
* **Fluxo (Sucesso):**
  1. `GET https://dummyjson.com/posts/{id}`.
  2. Sistema retorna `200 OK` com JSON do post.
* **Pós-condição:** Detalhes disponíveis para validação.
* **Erros:** UC-POST-002-E1: ID inexistente → `404 Not Found` com mensagem "Post with id '{id}' not found".

---

### **Caso de Uso 3: Listar Posts de um Usuário**
* **ID:** UC-POST-003
* **Título:** Obter posts associados a um usuário.
* **Descrição:** Lista todos os posts criados por um `userId`.
* **Pré-condições:** `userId` válido.
* **Fluxo (Sucesso):**
  1. `GET https://dummyjson.com/posts/user/{userId}`.
  2. Retorna `200 OK` com lista `posts` (pode ser vazia).
* **Alternativos:** UC-POST-003-A1: Usuário sem posts → lista vazia com `total=0`.

---

### **Caso de Uso 4: Buscar Posts por Palavra-Chave**
* **ID:** UC-POST-004
* **Título:** Buscar posts.
* **Descrição:** Pesquisa textual em posts.
* **Fluxo (Sucesso):**
  1. `GET https://dummyjson.com/posts/search?q={termo}`.
  2. Retorna `200 OK` com posts filtrados.
* **Fluxos Alternativos:**
  * UC-POST-004-A1: Termo sem correspondência → lista vazia (`posts=[]`, `total=0`).
  * UC-POST-004-A2: Combinar busca + paginação `?q={termo}&limit=5&skip=5`.
* **Erros:** UC-POST-004-E1: Query param ausente (`q=` vazio) — documentar resposta real observada.

---

### **Caso de Uso 5: Listar Todas as Tags de Posts**
* **ID:** UC-POST-005
* **Título:** Obter lista de tags.
* **Descrição:** Recupera todas as tags distintas existentes.
* **Fluxo (Sucesso):**
  1. `GET https://dummyjson.com/posts/tags` (ou endpoint equivalente da doc: `.../posts/#posts-tags`).
  2. Retorna `200 OK` com array simples de strings.
* **Pós-condição:** Lista disponível para cenários de filtragem.
* **Erros:** UC-POST-005-E1: Falha de rede.

---

### **Caso de Uso 6: Obter Lista de Objetos Tag (se aplicável)**
* **ID:** UC-POST-006
* **Título:** Obter metadados de tags.
* **Descrição:** Alguns endpoints oferecem estrutura adicional (ex.: `posts/tag/list`). Validar existência; se não houver, marcar como não aplicável.
* **Fluxo (Sucesso):**
  1. `GET https://dummyjson.com/posts/tag/list` (exemplo — ajustar conforme doc real se disponível).
  2. `200 OK` com coleção de objetos.
* **Alternativo:** UC-POST-006-A1: Endpoint inexistente → cenários marcados como `skip`.

---

### **Caso de Uso 7: Listar Posts por Tag**
* **ID:** UC-POST-007
* **Título:** Filtrar por tag.
* **Descrição:** Obtém posts associados a uma tag específica.
* **Fluxo (Sucesso):**
  1. `GET https://dummyjson.com/posts/tag/{tag}`.
  2. `200 OK` com `posts` correspondentes.
* **Alternativos:** UC-POST-007-A1: Tag inexistente → lista vazia.

---

### **Caso de Uso 8: Obter Comentários de um Post**
* **ID:** UC-POST-008
* **Título:** Listar comentários de um post.
* **Descrição:** Recupera comentários pertencentes a um post específico.
* **Fluxo (Sucesso):**
  1. `GET https://dummyjson.com/posts/{id}/comments`.
  2. `200 OK` com lista `comments` (pode ser vazia).
* **Erros:** UC-POST-008-E1: Post inexistente → `404 Not Found`.

---

### **Caso de Uso 9: Criar Novo Post (Simulado)**
* **ID:** UC-POST-009
* **Título:** Adicionar post.
* **Descrição:** Simula criação de novo post (não persistente globalmente).
* **Fluxo (Sucesso):**
  1. `POST https://dummyjson.com/posts/add` com body `{ "title": "...", "body": "...", "userId": 1 }`.
  2. Retorna `200 OK` com objeto contendo novo `id` e dados ecoados.
* **Erros:**
  * UC-POST-009-E1: Body inválido → possível `400 Bad Request`.
  * UC-POST-009-E2: Campo obrigatório ausente (`title` ou `body`).
* **Observação:** Não confiar em persistência subsequente.

---

### **Caso de Uso 10: Atualizar Post (Substituição)**
* **ID:** UC-POST-010
* **Título:** Atualizar completamente um post.
* **Fluxo (Sucesso):**
  1. `PUT https://dummyjson.com/posts/{id}` body completo.
  2. `200 OK` com objeto atualizado.
* **Erros:** UC-POST-010-E1: ID inexistente → `404 Not Found`.

---

### **Caso de Uso 11: Atualização Parcial (PATCH)**
* **ID:** UC-POST-011
* **Título:** Atualizar parcialmente um post.
* **Fluxo (Sucesso):**
  1. `PATCH https://dummyjson.com/posts/{id}` com subset de campos.
  2. `200 OK` com merge simulado.
* **Erros:** UC-POST-011-E1: ID inexistente → `404 Not Found`.

---

### **Caso de Uso 12: Deletar Post**
* **ID:** UC-POST-012
* **Título:** Deletar um post.
* **Descrição:** Simula exclusão retornando objeto com `isDeleted`.
* **Fluxo (Sucesso):**
  1. `DELETE https://dummyjson.com/posts/{id}`.
  2. `200 OK` com `{ id, isDeleted: true, deletedOn: <timestamp> }`.
* **Erros:** UC-POST-012-E1: ID inexistente → `404 Not Found`.

---

---

### **Notas Gerais (Posts)**
* Escritas simuladas (não persistem).
* Validar consistência de tipos (`reactions` numérico, `tags` array string).
* Cobrir interações: busca + paginação + ordenação.
* Mapear tags reais para massa determinística de testes.
