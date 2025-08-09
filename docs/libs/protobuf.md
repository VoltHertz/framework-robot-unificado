# Protocol Buffers (protobuf)

## Visão Geral
Protocol Buffers (protobuf) é o formato binário estruturado do Google para serialização eficiente de dados. No projeto, servirá de base para mensagens gRPC (futuro) e potencial intercâmbio de dados entre serviços. Benefícios: compactação, versionamento de campos, linguagem neutra.

## Conceitos Fundamentais
- `.proto`: arquivo de definição de schema (mensagens, enums, serviços RPC).
- Campos numerados: número do campo = tag/identificador no wire format (crucial para compatibilidade).
- Tipos: escalares (int32, int64, string, bool, bytes, etc.), mensagens aninhadas, enums, maps, oneof.
- Wire Types: varint, 64-bit, length-delimited, 32-bit (escondido do usuário, mas influencia performance em grandes volumes).
- Versionamento: adicionar campos novos com novos números; não reutilizar número removido; evitar mudar tipo/semântica de campo existente.

## Exemplo Básico `.proto`
```proto
syntax = "proto3";
package exemplo.v1;

message Produto {
  int64 id = 1;
  string nome = 2;
  double preco = 3;
  repeated string tags = 4;
  map<string,string> metadados = 5;
  oneof disponibilidade {
    bool ativo = 6;
    string motivo_inativo = 7;
  }
}

service CatalogoService {
  rpc ObterProduto (ObterProdutoRequest) returns (Produto);
}

message ObterProdutoRequest { int64 id = 1; }
```

## Geração de Código (Python)
Instalação runtime:
```
pip install protobuf
```
Compilação (supondo `protoc` no PATH):
```
protoc -I=grpc/proto --python_out=grpc/generated grpc/proto/catalogo.proto
```
Para gRPC Python (quando integrarmos):
```
pip install grpcio grpcio-tools
python -m grpc_tools.protoc -I=grpc/proto \
    --python_out=grpc/generated --grpc_python_out=grpc/generated \
    grpc/proto/catalogo.proto
```

## Boas Práticas de Schema
| Prática | Justificativa |
|---------|---------------|
| Reservar números removidos | Evita colisões futuras |
| Usar prefixo de pacote (ex: dominio.v1) | Namespacing + versionamento sem quebra |
| Campos opcionais bem definidos | Explicita presença (proto3 agora suporta `optional`) |
| Evitar default implícito sem documentação | Ambiguidade nos consumidores |
| Map vs repeated message | Map simplifica consulta chave->valor |
| oneof para variantes exclusivas | Evita múltiplos campos mutuamente excludentes |

## Evolução de Versão
- Pequenas mudanças compatíveis: adicionar campo novo com número novo.
- Quebra inevitável: criar novo pacote `dominio.v2`.
- Manter `CHANGELOG` ou doc de migração (futuro `docs/grpc/` no repositório).

## Integração Planejada no Projeto
1. Pasta `grpc/proto`: armazenar contratos.
2. Geração automática para `grpc/generated/` (não editar manual).
3. Camada adapter gRPC criará canal + stubs.
4. Services em Robot chamarão keywords Python wrapper que utilizam stubs gerados.

## Interoperabilidade com Dados de Teste
- Para massa dinâmica: gerar instâncias de mensagens via fábricas (Factory Pattern) convertendo para JSON quando necessário em asserts contract (ou validar binário via decode inverso).

## Exemplo Python Uso Gerado
```python
from grpc.generated import catalogo_pb2
produto = catalogo_pb2.Produto(id=1, nome="Teclado", preco=199.90, tags=["periferico"]) 
serialized = produto.SerializeToString()
# Enviar via gRPC ou armazenar
novo = catalogo_pb2.Produto()
novo.ParseFromString(serialized)
assert novo.id == 1
```

## Mapas, Repeated e oneof
- `repeated` retorna lista mutável Python.
- `map<string,string>` vira dict-like, mas não é um dict real (iterar com cuidado se mutar durante iteração).
- `oneof`: atribuir um campo limpa os demais mutuamente exclusivos.

## Performance
- Evitar conversões JSON se não necessárias (SerializeToString / ParseFromString é mais rápido).
- Mensagens muito grandes: considerar streaming gRPC ou chunking.

## Testes
- Fixtures: construir mensagens mínimas válidas.
- Contratos: comparar presença de campos (`HasField` para opcionais / oneof).

## Pitfalls e Mitigações
| Problema | Causa | Mitigação |
|----------|-------|-----------|
| Reuso de número de campo | Remoção sem reservar | Comentário `reserved` ou documentação |
| Campo trocado de tipo | Refactor perigoso | Criar novo campo e deprecar antigo |
| oneof inconsistente | Atribuir múltiplos campos | Validar `WhichOneof()` antes |
| Protoc versão divergente | Ferramenta vs runtime | Manter versão alinhada CI |
| Diretórios hardcoded | Caminhos relativos frágeis | Centralizar paths em script build |

## Referências Oficiais
- Repo: https://github.com/protocolbuffers/protobuf
- Descrição: https://protobuf.dev/
- Python API: https://protobuf.dev/reference/python/
- Style Guide: https://protobuf.dev/programming-guides/style/
