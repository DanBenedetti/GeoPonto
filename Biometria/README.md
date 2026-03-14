# 👤 Módulo de Biometria Facial - GeoPonto

Este diretório contém a inteligência artificial responsável pelo reconhecimento facial do sistema **GeoPonto**. O modelo foi desenvolvido utilizando técnicas de *Transfer Learning* e *Embeddings* para identificar usuários com precisão e rapidez.

## 🚀 Visão Geral

O sistema utiliza a arquitetura **MobileNetV3Small** (otimizada para dispositivos móveis) como base para extrair vetores numéricos únicos (*embeddings*) de cada rosto. A comparação entre dois rostos é feita calculando a **Distância Euclidiana** entre esses vetores.

## 📂 Estrutura de Arquivos

- `dataset_treino/`: Pasta contendo subpastas com fotos dos usuários (organizadas por nome).
- `testeouro/`: Dataset de validação com fotos reais para testes de precisão.
- `treinar_modelo.py`: Script principal para treinamento do extrator de características.
- `comparar_faces.py`: Script para testar a comparação entre duas imagens localmente.
- `gerar_metricas.py`: Gera relatórios de precisão, matriz de confusão e gráficos.
- `converter_para_tflite.py`: Converte o modelo treinado para o formato `.tflite` (usado no App Flutter).
- `geoponto_extractor.keras`: O modelo treinado e pronto para uso.

## 🛠️ Tecnologias Utilizadas

- **TensorFlow / Keras**: Criação e treinamento da rede neural.
- **MobileNetV3Small**: Arquitetura base leve para extração de características.
- **Matplotlib / Pandas**: Gerenciamento de dados e visualização de métricas.

## 📖 Como Usar

### 1. Preparar o Dataset
Coloque as fotos dos usuários na pasta `dataset_treino/`. Cada usuário deve ter sua própria subpasta com seu nome.
> Recomendado: Pelo menos 15-20 fotos por pessoa em diferentes ângulos e iluminações.

### 2. Treinar o Modelo
Execute o script de treinamento para gerar o extrator de biometria:
```bash
python treinar_modelo.py
```
Isso gerará o arquivo `geoponto_extractor.keras` e os gráficos de perda/acurácia.

### 3. Comparar Faces (Teste Manual)
Para verificar se o sistema reconhece duas fotos como a mesma pessoa:
```bash
python comparar_faces.py caminho/da/foto1.jpg caminho/da/foto2.jpg
```

### 4. Gerar Métricas de Desempenho
Para ver como o modelo se sai em um conjunto de testes e gerar o relatório acadêmico:
```bash
python gerar_metricas.py
```

### 5. Exportar para Mobile
Para usar a biometria dentro do aplicativo Flutter, converta o modelo para TFLite:
```bash
python converter_para_tflite.py
```

## ⚖️ Lógica de Validação (Threshold)

O sistema não retorna um "sim" ou "não" direto da rede neural. Ele calcula uma distância:
- **Distância < 1.1**: Mesma pessoa (Acesso Permitido ✅).
- **Distância >= 1.1**: Pessoas diferentes (Acesso Negado ❌).

*Nota: O valor de 1.1 (limiar) pode ser ajustado no arquivo `comparar_faces.py` conforme a necessidade de maior segurança ou maior tolerância.*

---
**Desenvolvido para o Projeto Integrador - FATEC**
