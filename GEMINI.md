# Projeto GeoPonto - Contexto de Desenvolvimento

Este arquivo serve como memória persistente para o Gemini CLI sobre o projeto GeoPonto.

## Visão Geral
O GeoPonto é um sistema de registro de ponto (presença) que utiliza biometria facial para validação.

## Estrutura do Projeto
- **`/backend`**: API desenvolvida em Python (provavelmente FastAPI ou Flask) com banco de dados SQL (`database.sql`). Contém scripts de automação (`back.sh`, `setup_vm.sh`).
- **`/frontend`**: Aplicação mobile/web desenvolvida em Flutter/Dart.
- **`/Biometria`**: Módulo de Inteligência Artificial para reconhecimento facial. Contém modelos em formatos `.h5`, `.keras` e `.tflite`, além de scripts para treinamento e comparação de faces.
- **Raiz**: Contém scripts utilitários como `start-dev.sh` e `generate_pontos.py`.

## Tecnologias Principais
- **Linguagens**: Python, Dart, SQL.
- **Frameworks**: Flutter (Frontend), Keras/TensorFlow (Biometria).
- **Dados**: SQLite/PostgreSQL (conforme `database.sql`).

## Instruções para o Gemini
- Sempre considere a integração entre o Backend e o Frontend ao sugerir mudanças.
- Ao trabalhar na pasta `/Biometria`, priorize a performance e precisão dos modelos, considerando que o destino final pode ser dispositivos móveis (via TFLite).
- Mantenha o padrão de nomes e a estrutura de diretórios existente.
