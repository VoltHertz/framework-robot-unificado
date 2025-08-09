# **Documentação de Casos de Uso – API DummyJSON Todos ([dummyjson.com/todos](https://dummyjson.com/todos))**
Api descrita em: `https://dummyjson.com/docs/todos`
---

### **Caso de Uso 1: Listar Todos os Todos**
* **ID:** UC-TODO-001
* **Fluxo (Sucesso):** `GET https://dummyjson.com/todos` → `200 OK` com `todos`, `total`, `skip`, `limit`.
* **Variações:**
	* UC-TODO-001-A1: Paginação custom `?limit=5&skip=10`.
	* UC-TODO-001-A2: `limit=0` retorna todos.
	* UC-TODO-001-A3: Ordenação (se suportada) `?sort=id&order=desc`.
* **Erros:** UC-TODO-001-E1: `limit` inválido.

### **Caso de Uso 2: Obter Todo por ID**
* **ID:** UC-TODO-002
* **Fluxo (Sucesso):** `GET https://dummyjson.com/todos/{id}` → `200 OK` objeto.
* **Erros:**
	* UC-TODO-002-E1: ID inexistente.
	* UC-TODO-002-E2: ID não numérico (validar resposta real e documentar).

### **Caso de Uso 3: Listar Todos de um Usuário**
* **ID:** UC-TODO-003
* **Fluxo (Sucesso):** `GET https://dummyjson.com/todos/user/{userId}` → lista (pode ser vazia).
* **Alternativos:**
	* UC-TODO-003-A1: Usuário sem tarefas → lista vazia.
	* UC-TODO-003-A2: Paginação sobre tarefas do usuário `?limit=2&skip=1`.
* **Erros:** UC-TODO-003-E1: `userId` inválido.

### **Caso de Uso 4: Obter Todo Aleatório**
* **ID:** UC-TODO-004
* **Fluxo (Sucesso):** `GET https://dummyjson.com/todos/random` → `200 OK` com um item aleatório (validar variação em múltiplas chamadas).
* **Variações:** UC-TODO-004-A1: `/todos/random/10` caso a doc suporte comprimento máximo (confirmar doc). 
* **Notas:** Item muda a cada chamada.

### **Caso de Uso 5: Criar Novo Todo (Simulado)**
* **ID:** UC-TODO-005
* **Fluxo (Sucesso):** `POST https://dummyjson.com/todos/add` body `{ todo, userId, completed }` (campos mínimos) → `200 OK` com novo `id`.
* **Erros:**
	* UC-TODO-005-E1: Body inválido.
	* UC-TODO-005-E2: Campo obrigatório ausente (`todo`).

### **Caso de Uso 6: Atualizar Todo (PUT)**
* **ID:** UC-TODO-006
* **Fluxo (Sucesso):** `PUT https://dummyjson.com/todos/{id}` → `200 OK` objeto atualizado.
* **Erros:** UC-TODO-006-E1: ID inexistente.

### **Caso de Uso 7: Atualizar Parcialmente (PATCH)**
* **ID:** UC-TODO-007
* **Fluxo (Sucesso):** `PATCH https://dummyjson.com/todos/{id}`.
* **Erros:** UC-TODO-007-E1: ID inexistente.

### **Caso de Uso 8: Deletar Todo**
* **ID:** UC-TODO-008
* **Fluxo (Sucesso):** `DELETE https://dummyjson.com/todos/{id}` → retorna objeto com `isDeleted`.
* **Erros:** UC-TODO-008-E1: ID inexistente.

### **Notas**
* Escritas simuladas (sem persistência real).
* Validar campo booleano `completed` e consistência `id` numérico.
* Testar sequência: criar → atualizar → deletar (mesmo sabendo que estado não persiste) apenas para validar formato.
