# 👤 Módulo de Biometria Facial - GeoPonto

Este diretório contém a inteligência artificial responsável pelo reconhecimento facial do sistema **GeoPonto**. O projeto foca no desenvolvimento de um extrator de características faciais (*embeddings*) construído do zero utilizando a arquitetura **MobileNetV3Small**.

## 🚀 Metodologia Acadêmica
Seguindo os requisitos do Projeto Integrador (PI), o modelo foi treinado **integralmente do zero** (weights=None). Esta abordagem demonstra o domínio sobre a arquitetura de redes neurais, superando o desafio de ensinar a visão computacional sem o uso de pesos pré-existentes.

## 🏆 Modelo Homologado: V8.3.1 (Ajuste Cirúrgico)
Após diversos ciclos de refinamento, a versão **8.3.1** foi selecionada para produção:
- **Arquivo**: `geoponto_extractor_v8_3_1.keras`
- **Acurácia (Vida Real)**: 84.06%
- **Threshold Calibrado**: 1.80 (Equilíbrio entre segurança e usabilidade)

---

## 📊 Análise de Resultados e Evolução

O treinamento foi dividido em fases estratégicas para superar obstáculos de convergência inerentes ao treinamento do zero:

### 1. Fases Iniciais (Construção da Base)
- **Fase 1:** Inicialização com 10k identidades (Acurácia 0.3%).
- **Fase 2:** Filtragem para 1.000 identidades densas (Início da convergência).
- **Fase 3:** Salto de acurácia para **3.06%** via ajuste de Learning Rate.
- **Fase 4:** Consolidação com **6.86%** de acurácia.
- **Fase 5:** Teste com 200 identidades (**8.5%**), posteriormente arquivado para focar em base maior.

### 2. Refinamento de Robustez (Fase 6 e 7)
- **Estratégia:** Inclusão de `RandomBrightness` e `GaussianNoise`.
- **V2:** Acurácia de **7.39%** com dados ruidosos.
- **V3 (Deep Refinement):** Estabilização em **8.66%** em 1.000 classes.

### 3. Especialização e Alta Performance (Fase 8)
- **Cenário:** Seleção das 250 identidades mais densas do CelebA.
- **Fase 8.1:** Refinamento máximo atingindo **16.37%** de acurácia de classificação e **86.50%** de verificação teórica.
- **Fase 8.3.1 (Atual):** Ajuste cirúrgico final utilizando SGD, focado em compactação de clusters para uso em ambiente real.

---

## 🛠️ Engenharia de Refinamento (Ferramentas Utilizadas)

Para atingir o estado de homologação, aplicamos as seguintes técnicas avançadas:

### 1. SGD com Momentum (Nesterov)
- **Objetivo**: Proporcionar um "polimento" estável aos pesos. Diferente de otimizadores de passo rápido, o SGD com Momentum evita oscilações bruscas, permitindo que o modelo encontre o ponto ideal de separação entre faces similares.

### 2. Cosine Decay (Decaimento Cosseno)
- **Objetivo**: Ajustar o ritmo de aprendizado de forma orgânica. O modelo começa explorando mudanças maiores e termina o treino com ajustes microscópicos, refinando a posição dos rostos no mapa de embeddings sem "chutar" o modelo para fora da convergência.

### 3. Label Smoothing (Suavização de Rótulos)
- **Objetivo**: Combater a "decoreba" (*overfitting*). Ao não permitir que o modelo tenha 100% de certeza absoluta durante as fases intermediárias, forçamos a rede a aprender características faciais genéricas que funcionam em fotos novas (como as do dataset de teste real).

### 4. Compactação de Clusters
- **Objetivo**: Reduzir a distância intra-classe. Na fase final, removemos a suavização para forçar o modelo a aproximar ao máximo as fotos da mesma pessoa, reduzindo a distância média de **2.37** para **1.46**.

---

## 📂 Estrutura do Módulo
- `geoponto_extractor_v8_3_1.keras`: Extrator final homologado.
- `comparar_faces.py`: Script principal de comparação (1:1) para integração.
- `testar_matriz.py`: Script de validação cruzada entre múltiplos usuários.
- `treinar_modelo_*.py`: Histórico de scripts de treinamento de todas as fases.

---
**Desenvolvido para o Projeto Integrador - FATEC**
