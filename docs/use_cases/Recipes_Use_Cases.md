# **Documentação de Casos de Uso – API DummyJSON Recipes ([dummyjson.com/recipes](https://dummyjson.com/recipes))**
Api descrita em: `https://dummyjson.com/docs/recipes`
---

### **Caso de Uso 1: Listar Receitas (Paginação)**
* **ID:** UC-REC-001
* **Fluxo (Sucesso):** `GET https://dummyjson.com/recipes` → `200 OK` com `recipes`, `total`, `skip`, `limit`.
* **Variações:**
	* UC-REC-001-A1: Paginação custom.
	* UC-REC-001-A2: `limit=0` retorna todos.
	* UC-REC-001-A3: Ordenação `?sort=name&order=asc` (validar se suportado; caso não, documentar comportamento).
* **Erros:** UC-REC-001-E1: `limit` inválido.

### **Caso de Uso 2: Obter Receita por ID**
* **ID:** UC-REC-002
* **Fluxo (Sucesso):** `GET https://dummyjson.com/recipes/{id}` → `200 OK` objeto.
* **Erro:** UC-REC-002-E1: ID inexistente.

### **Caso de Uso 3: Buscar Receitas (Texto)**
* **ID:** UC-REC-003
* **Fluxo (Sucesso):** `GET https://dummyjson.com/recipes/search?q={termo}`.
* **Alternativos:**
	* UC-REC-003-A1: Sem resultados.
	* UC-REC-003-A2: Combinar com paginação `?q={termo}&limit=5&skip=5`.
* **Erros:** UC-REC-003-E1: Query vazia.

### **Caso de Uso 4: Listar Tags Disponíveis**
* **ID:** UC-REC-004
* **Fluxo (Sucesso):** `GET https://dummyjson.com/recipes/tags` → `200 OK` lista de tags.

### **Caso de Uso 5: Filtrar Receitas por Tag**
* **ID:** UC-REC-005
* **Fluxo (Sucesso):** `GET https://dummyjson.com/recipes/tag/{tag}` → receitas relacionadas.
* **Alternativos:**
	* UC-REC-005-A1: Tag inexistente → lista vazia.
	* UC-REC-005-A2: Paginação aplicada `?limit=5&skip=5`.

### **Caso de Uso 6: Filtrar Receitas por Tipo de Refeição**
* **ID:** UC-REC-006
* **Fluxo (Sucesso):** `GET https://dummyjson.com/recipes/meal-type/{mealType}` → receitas correspondentes.
* **Alternativos:** UC-REC-006-A1: Tipo inexistente → lista vazia.

### **Caso de Uso 7: Filtrar Receitas por Tipo de Refeição**
* **ID:** UC-REC-006
* **Fluxo (Sucesso):** `GET https://dummyjson.com/recipes/meal-type/{mealType}`.
* **Alternativos:**
	* UC-REC-006-A1: Tipo inexistente → lista vazia.
	* UC-REC-006-A2: Paginação.

### **Caso de Uso 8: Criar Receita (Simulado)**
* **ID:** UC-REC-007
* **Fluxo (Sucesso):** `POST https://dummyjson.com/recipes/add` body mínimo (ex.: `name`, `ingredients`, `instructions`).
* **Erros:** UC-REC-007-E1: Body inválido.

### **Caso de Uso 9: Atualizar Receita (PUT/PATCH Simulado)**
* **ID:** UC-REC-008
* **Fluxo (Sucesso):** `PUT` ou `PATCH https://dummyjson.com/recipes/{id}` → objeto atualizado.
* **Erros:** UC-REC-008-E1: ID inexistente.

### **Caso de Uso 10: Deletar Receita (Simulado)**
* **ID:** UC-REC-009
* **Fluxo (Sucesso):** `DELETE https://dummyjson.com/recipes/{id}` → objeto com `isDeleted`.
* **Erros:** UC-REC-009-E1: ID inexistente.

### **Notas**
* Escritas simuladas.
* Validar campos: `ingredients` (array), `instructions` (array), `tags` (array), `mealType` (string/array).
* Testar paginar + filtrar simultaneamente.
