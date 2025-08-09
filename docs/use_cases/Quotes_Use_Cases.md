# **Documentação de Casos de Uso – API DummyJSON Quotes ([dummyjson.com/quotes](https://dummyjson.com/quotes))**
Api descrita em: `https://dummyjson.com/docs/quotes`
---

### **Caso de Uso 1: Listar Quotes (Paginação)**
* **ID:** UC-QUO-001
* **Fluxo (Sucesso):** `GET https://dummyjson.com/quotes` → `200 OK` com `quotes`, `total`, `skip`, `limit`.
* **Variações:**
	* UC-QUO-001-A1: `?limit=5&skip=10`.
	* UC-QUO-001-A2: `limit=0` retorna todos.
	* UC-QUO-001-A3: Ordenação (se suportada) `?sort=author&order=asc`.
* **Erros:** UC-QUO-001-E1: `limit` inválido.

### **Caso de Uso 2: Obter Quote por ID**
* **ID:** UC-QUO-002
* **Fluxo (Sucesso):** `GET https://dummyjson.com/quotes/{id}` → `200 OK` objeto.
* **Erro:** UC-QUO-002-E1: ID inexistente → `404 Not Found`.

### **Caso de Uso 3: Buscar Quotes (Texto)**
* **ID:** UC-QUO-003
* **Fluxo (Sucesso):** `GET https://dummyjson.com/quotes/search?q={termo}` → `200 OK` lista filtrada.
* **Alternativos:**
	* UC-QUO-003-A1: Sem match → lista vazia.
	* UC-QUO-003-A2: Combinar com paginação `?q={termo}&limit=5&skip=5`.
* **Erros:** UC-QUO-003-E1: Query vazia.

### **Caso de Uso 4: Quote Aleatória**
* **ID:** UC-QUO-004
* **Descrição:** Obter uma quote aleatória (endpoint oficial `GET /quotes/random`).
* **Fluxo (Sucesso):** `GET https://dummyjson.com/quotes/random` → `200 OK` quote única.
* **Alternativos:** UC-QUO-004-A1: Repetir múltiplas vezes e validar variação dos IDs (teste probabilístico).

### **Notas**
* Apenas leitura (sem criação/edição).
* Validar: `id`, `quote`, `author`.
