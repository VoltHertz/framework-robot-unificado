# **Documentação de Casos de Uso – API DummyJSON Comments ([dummyjson.com/comments](https://dummyjson.com/comments))**
Api descrita em: `https://dummyjson.com/docs/comments`
---

### **Caso de Uso 1: Listar Comentários (Paginação)**
* **ID:** UC-COM-001
* **Título:** Obter lista paginada de comentários.
* **Fluxo (Sucesso):** `GET https://dummyjson.com/comments` → `200 OK` com `comments`, `total`, `skip`, `limit`.
* **Variações:**
	* UC-COM-001-A1: Paginação custom `?limit=5&skip=5`.
	* UC-COM-001-A2: `limit=0` → retorna todos.
	* UC-COM-001-A3: Ordenação (se suportado) `?sort=id&order=desc`.
* **Erros:** UC-COM-001-E1: `limit` inválido.

### **Caso de Uso 2: Obter Comentário por ID**
* **ID:** UC-COM-002
* **Fluxo (Sucesso):** `GET https://dummyjson.com/comments/{id}` → `200 OK` com objeto.
* **Erro:** UC-COM-002-E1: ID inexistente → `404 Not Found`.

### **Caso de Uso 3: Listar Comentários de um Post**
* **ID:** UC-COM-003
* **Fluxo (Sucesso):** `GET https://dummyjson.com/comments/post/{postId}` → `200 OK` lista (pode ser vazia).
* **Alternativos:**
	* UC-COM-003-A1: `postId` sem comentários → lista vazia.
	* UC-COM-003-A2: Paginação combinada `?limit=5&skip=5`.
* **Erros:** UC-COM-003-E1: Post inexistente → `404 Not Found`.

### **Caso de Uso 4: Criar Comentário (Simulado)**
* **ID:** UC-COM-004
* **Fluxo (Sucesso):** `POST https://dummyjson.com/comments/add` body `{ body, postId, userId }` → `200 OK` com novo `id`.
* **Erros:**
	* UC-COM-004-E1: Body inválido → `400 Bad Request`.
	* UC-COM-004-E2: Campo obrigatório faltante (`body`).

### **Caso de Uso 5: Atualizar Comentário (PUT)**
* **ID:** UC-COM-005
* **Fluxo (Sucesso):** `PUT https://dummyjson.com/comments/{id}` → `200 OK` objeto atualizado.
* **Erro:** UC-COM-005-E1: ID inexistente.

### **Caso de Uso 6: Atualização Parcial (PATCH)**
* **ID:** UC-COM-006
* **Fluxo (Sucesso):** `PATCH https://dummyjson.com/comments/{id}`.
* **Erro:** UC-COM-006-E1: ID inexistente.

### **Caso de Uso 7: Deletar Comentário**
* **ID:** UC-COM-007
* **Fluxo (Sucesso):** `DELETE https://dummyjson.com/comments/{id}` → objeto com `isDeleted`.
* **Erro:** UC-COM-007-E1: ID inexistente.

### **Notas**
* Escritas simuladas (não persistem globalmente).
* Validar integridade cruzada: `user.id`, `postId`.
* Considerar massa determinística para busca futura (se houver endpoint de search para comments em versões posteriores).
