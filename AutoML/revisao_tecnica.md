# Revisao Tecnica

## Achados

### Alta prioridade
- `app.py` concentra interface, preprocessamento, treino e exportacao.
- Ha duplicacao entre `app.py` e os modulos separados.
- As dependencias declaradas ainda nao cobrem tudo que o codigo usa.
- Falta uma validacao forte do dataset antes do treino.

### Media prioridade
- O projeto precisa de testes automatizados.
- Nao ha rastreio padrao de experimentos.
- O tratamento de datasets grandes pode ficar caro em tempo e memoria.

### Baixa prioridade
- Melhorar logs.
- Melhorar explicabilidade.
- Padronizar melhor a exportacao de artefatos.

## Melhorias tecnicas profundas
1. Criar um pacote `core/` com preprocessamento, treino e relatorios.
2. Transformar `app.py` em orquestrador fino.
3. Definir contratos claros entre modulos.
4. Salvar pipelines completos, nao apenas o modelo final.
5. Criar validacao de schema e qualidade dos dados.
6. Adicionar testes de integracao para o fluxo completo.

## Observacao final
A base e boa para demonstracao, mas ainda pede consolidacao estrutural antes de evoluir para manutencao de longo prazo.
