# Projeto GeoPonto - Contexto de Desenvolvimento (Atualizado em 17/03/2026)

Este arquivo serve como memória persistente para o Gemini CLI sobre o projeto GeoPonto.

## Visão Geral
O GeoPonto é um sistema de registro de ponto com biometria facial construído do zero (MobileNetV3, weights=None).

## Estrutura do Projeto
- **`/backend`**: API desenvolvida em Python (FastAPI) com banco de dados SQL (`database.sql`). Contém scripts de automação (`back.sh`, `setup_vm.sh`).
- **`/frontend`**: Aplicação mobile/web desenvolvida em Flutter/Dart.
- **`/Biometria`**: Módulo de IA para reconhecimento facial. Contém modelos (`.keras`), scripts de treino, conversão TFLite e comparação de faces.
- **Raiz**: Scripts utilitários como `start-dev.sh` e modelos homologados.

## Tecnologias Principais
- **Linguagens**: Python, Dart, SQL.
- **Frameworks**: Flutter (Frontend), Keras/TensorFlow (Biometria).
- **Dados**: SQLite/PostgreSQL.

## Status Técnico e Fases de Treinamento

### Histórico Completo de Execução
O treinamento é realizado em fases incrementais para permitir controle de convergência e documentação para o PI:

| Fase | Descrição | Classes | Épocas | Loss | Acc (Val) | Data | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Fase 1** | Inicialização do Zero | 10.177 | 45 | ~9.39 | 0.3% | 15/03 | Concluído |
| **Fase 2** | Otimização (Densas) | 1.000 | 100 | 6.47 | 0.53% | 15/03 | Concluído |
| **Fase 3** | Impulso (LR 0.0005) | 1.000 | 100 | 5.63 | 3.06% | 16/03 | Concluído |
| **Fase 4** | Refinamento (LR 0.0002) | 1.000 | 100 | 5.26 | 6.86% | 16/03 | Concluído |
| **Fase 5** | Especialização Gold | 200 | 21 | 4.66 | 8.50% | 16/03 | Arquivado |
| **Fase 4 V2**| Refinamento (Brilho/Ruído) | 1.000 | 53 | 5.16 | 7.39% | 17/03 | Concluído |
| **Fase 4 V3**| Deep Refinement | 1.000 | 100 | 4.96 | 8.66% | 17/03 | Homologado |
| **Fase 8** | Especialista Elite | 250 | 55 | 5.31 | 11.95%| 17/03 | Superado |
| **Fase 8.1** | Refinamento Especialista | 250 | 100 | 4.82 | 16.37%| 17/03 | Superado |
| **Fase 8.2** | Refinado Estável (Adam) | 250 | 83 | ~4.3 | 28.37%| 18/03 | Regressão (72% 1:1)|
| **Fase 8.3** | Refinamento Precisão (SGD)| 250 | 32 | ~4.8 | 13.27%| 18/03 | Evolução (81% 1:1) |
| **Fase 8.3.1**| Ajuste Cirúrgico (SGD) | 250 | 32 | ~4.7 | 17.17%| 18/03 | **Homologado (84%)**|

### Melhores Resultados de Verificação (1:1)
- **Modelo Homologado:** `geoponto_extractor_v8_3_1.keras`
- **Acurácia Vida Real:** 84.06% (Testado com Danilo, Gabriel, Rangel e figuras públicas)
- **Threshold Sugerido:** 1.80 (Calibrado para uso em App)
- **Diferencial:** Treinado com SGD (Stochastic Gradient Descent) e sem Label Smoothing no estágio final para máxima compactação de embeddings.

## Estratégia Atual: Finalização e Integração
O ciclo de treinamento de biometria foi encerrado com sucesso na Fase 8.3.1. O modelo demonstra alta capacidade de distinção entre os usuários do sistema GeoPonto.
## Próximos Passos (App)
- Converter o modelo `geoponto_extractor_v8_3_1.keras` para `.tflite`.
- Integrar o arquivo TFLite no App Flutter.
- Utilizar o threshold de **1.80** para validação de ponto.

---
## Instruções para o Gemini
- Utilize o ambiente virtual em `GeoPonto/Biometria/venv/`.
- O script de teste oficial é o `GeoPonto/Biometria/validacao_real.py`.
- O modelo final homologado é o `geoponto_extractor_v8_3_1.keras`.
--- End of Context from: GeoPonto/GEMINI.md ---

