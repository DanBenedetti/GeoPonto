# 👤 Módulo de Biometria Facial - GeoPonto

Este diretório contém a inteligência artificial responsável pelo reconhecimento facial do sistema **GeoPonto**. O projeto foca no desenvolvimento de um extrator de características faciais (*embeddings*) construído do zero utilizando a arquitetura **MobileNetV3Small**.

## 🚀 Metodologia Acadêmica
Seguindo os requisitos do Projeto Integrador (PI), o modelo foi treinado **integralmente do zero** (weights=None). Esta abordagem demonstra o domínio sobre a arquitetura de redes neurais, superando o desafio de ensinar a visão computacional sem o uso de pesos pré-existentes.

### 📚 Dataset Principal: CelebA
Para o treinamento, utilizamos o dataset **CelebA (Large-scale CelebFaces Attributes Dataset)**, um dos padrões ouro na academia para tarefas de visão computacional facial.
*   **Link Oficial:** [CelebA Dataset](https://mmlab.ie.cuhk.edu.hk/projects/CelebA.html)
*   **Volume:** Mais de 200.000 imagens de celebridades com grande variação de pose, iluminação e atributos.
*   **Uso no GeoPonto:** Extraímos identidades com alta densidade de amostras para garantir que o modelo aprendesse a extrair *embeddings* invariantes de uma mesma pessoa.

### Especificações Técnicas da Arquitetura:
*   **Base:** MobileNetV3Small (escolhida pela eficiência em dispositivos móveis).
*   **Entrada:** Tensores de 224x224x3 pixels (RGB).
*   **Saída:** Vetor de características (*Embedding*) de 128 dimensões.
*   **Inicialização:** Pesos aleatórios, forçando o aprendizado de padrões geométricos faciais básicos desde a primeira época.

---

## ⚙️ Configuração do Ambiente

Para reproduzir os testes ou continuar o desenvolvimento, siga os passos abaixo:

1.  **Ambiente Virtual:** Recomendado Python 3.10 ou superior.
    ```bash
    cd GeoPonto/Biometria
    python -m venv venv
    source venv/bin/activate  # No Windows: venv\Scripts\activate
    ```
2.  **Dependências Principais:**
    *   `tensorflow>=2.15`: Framework de Deep Learning.
    *   `numpy` & `scipy`: Cálculos matemáticos e distância euclidiana.
    *   `opencv-python`: Manipulação de imagens.
    *   `matplotlib`: Geração de gráficos de métricas.

---

## 📊 Ciclo de Desenvolvimento em 8 Etapas

Para superar os desafios de convergência, seguimos uma estratégia de 8 passos fundamentais:

| Passo | Fase | Objetivo Técnico | Resultado (Acurácia) |
| :--- | :--- | :--- | :--- |
| **1** | Inicialização | Treino massivo com 10.177 identidades (CelebA completo). | 0.3% (Início) |
| **2** | Otimização | Filtragem para as 1.000 identidades mais densas (>30 fotos). | 0.53% |
| **3** | Impulso | Ajuste de Learning Rate (0.0005) para quebra de gradiente. | 3.06% |
| **4** | Refinamento | Estabilização de pesos e redução de oscilações (LR 0.0002). | 6.86% |
| **5** | Robustez | Inclusão de Brilho e Ruído Gaussiano para "Vida Real". | 7.39% |
| **6** | Especialização | Foco em Dataset Elite (250 classes de alta frequência). | 11.95% |
| **7** | Polimento | Transição de Adam para **SGD com Momentum** (Nesterov). | 28.37% |
| **8** | Ajuste Cirúrgico| LR baixíssima (5e-6) e remoção de Label Smoothing. | **84.06% (1:1)** |

---

## 📈 Métricas e Auditoria Visual

Para garantir a transparência acadêmica do Projeto Integrador, as métricas de convergência e as matrizes de confusão de cada fase crítica estão documentadas abaixo:

### Evolução das Matrizes de Confusão
As matrizes de confusão demonstram a capacidade do modelo em distinguir entre centenas de identidades simultâneas.
*   **[Fase 1: Inicialização Massiva](metricas_fases/metricas_fase_1/matriz_confusao.png)** - Alta dispersão inicial.
*   **[Fase 2: Otimização 1.000 classes](metricas_fases/metricas_fase_2/matriz_confusao.png)** - Início da formação de clusters.
*   **[Fase 3: Impulso de Gradiente](metricas_fases/metricas_fase_3/matriz_confusao.png)** - Refinamento da diagonal principal.
*   **[Fase 4: Refinamento de Pesos](metricas_fases/metricas_fase_4/matriz_confusao.png)** - Consolidação da acurácia base.
*   **[Fase 4 V2: Robustez Visual](metricas_fases/fase4_v2_refinado/matriz_confusao_v2.png)** - Matriz após injeção de ruído.

### Validação de Verificação (1:1)
Diferente da classificação, a verificação foca na distância euclidiana entre duas fotos.
*   **[Histograma de Frequência - Fase 8](metricas_fases/fase8_1_baseline/histograma_verificacao.png)**: Visualização da separação entre "Mesma Pessoa" e "Pessoas Diferentes".
*   **[Validação em Ambiente Real](metricas_fases/validacao_vida_real/histograma_real.png)**: Desempenho do modelo com fotos capturadas fora do dataset.
*   **[Comparativo Final Científico](metricas_fases/comparativo_final_cientifico.png)**: Gráfico consolidado demonstrando a evolução da acurácia ao longo das 8 fases.

---

## 🛠️ Detalhamento Estratégico por Fase

### 1. Inicialização Massiva (Cold Start)
Nesta fase inaugural, partimos de um cenário de incerteza total: o modelo foi inicializado sem qualquer conhecimento prévio (pesos aleatórios) e exposto a um conjunto massivo de 10.177 identidades do dataset CelebA. O desafio aqui era quebrar a inércia dos pesos iniciais e forçar a rede a começar a identificar formas geométricas básicas que compõem um rosto humano. Embora a acurácia tenha começado em 0.3%, esta etapa foi fundamental para "amolecer" o gradiente da rede.

**Ferramentas utilizadas:**
*   **Otimizador Adam:** Algoritmo que ajusta os pesos da rede automaticamente.
    *   *O que faz:* Funciona como um "piloto automático" que define a velocidade de aprendizado para cada neurônio.
    *   *Por que:* Escolhido por ser o mais eficiente para tirar a rede da estagnação inicial em treinamentos do zero.
*   **Categorical Crossentropy:** Função de erro para múltiplas classes.
    *   *O que faz:* Compara a previsão do modelo com o rótulo real e gera uma "nota de erro".
    *   *Por que:* É o padrão acadêmico para classificar milhares de identidades simultaneamente.
*   **Global Average Pooling 2D:** Camada de resumo de pixels.
    *   *O que faz:* Transforma mapas complexos de pixels em vetores simples, reduzindo conexões.
    *   *Por que:* Vital para evitar o **Overfitting** (decoreba), forçando o modelo a aprender formas em vez de pixels exatos.

### 2. Otimização e Limpeza de Dados
Observando os resultados da Fase 1, percebemos que a rede estava "confusa" devido à alta fragmentação: muitas identidades possuíam apenas 2 ou 3 fotos, o que não permitia o aprendizado de características invariantes. Implementamos uma estratégia de filtragem, reduzindo o escopo para as 1.000 identidades mais densas (com mais de 30 fotos cada). Além disso, otimizamos o pipeline de processamento para que o hardware pudesse ler as imagens mais rápido, permitindo mais iterações por hora.

**Ferramentas utilizadas:**
*   **Prefetch (tf.data):** Técnica de carregamento antecipado de dados.
    *   *O que faz:* Prepara o próximo lote de fotos enquanto a CPU processa o atual.
    *   *Por que:* Escolhido para eliminar gargalos de disco (I/O) e acelerar o treino em 40%.

### 3. Impulso e 4. Refinamento (Busca de Estabilidade)
Com o dataset agora otimizado, a acurácia começou a subir, mas o modelo ainda apresentava oscilações bruscas. Na Fase 3, aplicamos um "impulso" na taxa de aprendizado para forçar a rede a sair de patamares estagnados. Já na Fase 4, partindo dessa nova base, invertemos a estratégia: reduzimos a velocidade de aprendizado e introduzimos penalizações matemáticas para evitar que os pesos "explodissem", buscando uma convergência estável e segura para os primeiros testes de verificação.

**Ferramentas utilizadas:**
*   **ReduceLROnPlateau:** Monitor de progresso.
    *   *O que faz:* Reduz a "velocidade" (Learning Rate) se o erro parar de cair por um tempo determinado.
    *   *Por que:* Permite que o modelo se aproxime do valor ideal com passos mais cautelosos, evitando que ele "pule" o ponto de melhor acurácia.
*   **L2 Regularization:** Penalização de pesos altos.
    *   *O que faz:* "Multa" neurônios que tentam dominar o aprendizado sozinhos.
    *   *Por que:* Garante que a rede aprenda o rosto como um todo, e não apenas uma característica isolada (como apenas o olho ou o queixo).

### 5. Robustez à Vida Real (Deep Refinement)
A acurácia de 6.8% em 1.000 classes já era promissora, mas ao testar o modelo fora do ambiente de laboratório, ele falhava. Percebemos que as fotos do CelebA eram "perfeitas" demais. Na Fase 5, injetamos artificialmente variações de brilho e ruídos digitais nas imagens de treino. Isso forçou o modelo a aprender a ignorar a qualidade da câmera e focar apenas na geometria facial, preparando-o para o uso prático em celulares de diferentes qualidades.

**Ferramentas utilizadas:**
*   **Gaussian Noise & Random Brightness:** Camadas de distorção proposital.
    *   *O que faz:* Adiciona chuviscos e varia a luz das fotos de forma aleatória durante o treino.
    *   *Por que:* Força o modelo a ser resiliente. No aplicativo real, a iluminação nunca é constante.

### 6. Especialização e Alta Performance
Partindo de um modelo já robusto contra ruídos, decidimos estreitar o foco para maximizar a acurácia. Selecionamos as 250 identidades "Elite" (com maior número de exemplos e variação de ângulo). Aumentamos a "paciência" da rede e introduzimos técnicas de redundância, forçando a rede a criar múltiplos caminhos internos para reconhecer a mesma pessoa, o que elevou a acurácia para quase 12% em classificação massiva.

**Legenda de Ferramentas:**
*   **Dropout (0.4):** Desligamento aleatório de neurônios.
    *   *O que faz:* "Apaga" 40% da rede a cada rodada de treino.
    *   *Por que:* Cria resiliência, impedindo que o modelo decore fotos específicas e forçando-o a aprender traços genéricos.
*   **Unit Normalization:** Normalização de vetores.
    *   *O que faz:* Garante que o RG digital do rosto (embedding) tenha sempre o mesmo "tamanho" matemático.
    *   *Por que:* Facilita a comparação de rostos no aplicativo, focando apenas na diferença de formato e não na intensidade de cor.

### 7. Polimento Estável (Transição SGD)
Nesta fase crítica, percebemos que o otimizador Adam, embora rápido, estava causando oscilações microscópicas que impediam o modelo de atingir o "mínimo global" do erro. Partindo do peso alcançado na Fase 6, trocamos o motor do treinamento para o SGD (Stochastic Gradient Descent). Esta transição permitiu um polimento muito mais fino e estável, resultando em um salto de performance e estabilidade nos clusters de rostos.

**Ferramentas utilizadas:**
*   **SGD com Momentum e Nesterov:** Otimizador clássico de alta precisão.
    *   *O que faz:* Usa a "inércia" dos passos anteriores para deslizar suavemente até o erro mínimo.
    *   *Por que:* Enquanto o Adam é bom para exploração inicial, o SGD é superior para o ajuste fino final, garantindo uma convergência mais sólida.

### 8. Ajuste Cirúrgico Final (Homologação V8.3.1)
No último passo antes da implantação, realizamos o ajuste cirúrgico. Partindo da base estável do SGD, reduzimos a taxa de aprendizado ao nível mínimo e removemos as "suavizações" de erro. O objetivo era forçar o modelo a ter certeza máxima de cada face. O resultado foi a compactação final dos clusters: agora, duas fotos da mesma pessoa resultam em embeddings quase idênticos, permitindo o threshold de 1.80 homologado para o App.

**Ferramentas utilizadas:**
*   **Remoção de Label Smoothing:** Endurecimento de rótulos.
    *   *O que faz:* Para de dar "benefício da dúvida" ao erro e exige precisão total.
    *   *Por que:* Essencial para que os rostos da mesma pessoa fiquem matematicamente próximos.
*   **Early Stopping:** Sensor de parada automática.
    *   *O que faz:* Desliga o treinamento no exato momento em que ele para de evoluir.
    *   *Por que:* Previne o super-treinamento (OverFit) e garante que salvaremos a melhor versão possível da IA.

---

## 🏆 Modelo Homologado: V8.3.1
O modelo final (`geoponto_extractor_v8_3_1.keras`) obteve os seguintes resultados:
- **Acurácia (Verificação 1:1):** 84.06%
- **Threshold Sugerido:** 1.80 (Distância Euclidiana L2).
- **Justificativa Técnica:** O valor de **1.80** foi calibrado através de testes de matriz cruzada (identidades reais vs. famosas). Valores abaixo de 1.80 indicam alta similaridade (mesma pessoa), enquanto valores acima de 2.0 garantem a distinção de identidades diferentes em condições normais de iluminação.
- **Compactação Intra-classe:** Redução da distância média entre fotos da mesma pessoa de 2.37 para 1.46.

---

## 🔄 Fluxo de Processamento Facial

O funcionamento técnico da biometria segue este fluxo linear de processamento:

1.  **Captura:** O App Flutter envia a imagem bruta para o modelo.
2.  **Pré-processamento:** Redimensionamento para 224x224 e normalização de brilho.
3.  **Extração:** A rede neural MobileNetV3 processa os pixels e gera um vetor matemático.
4.  **RG Digital:** O resultado é um `embedding` de 128-D (uma sequência única de números).
5.  **Comparação:** O sistema calcula a distância matemática entre o embedding da foto atual e o embedding salvo no cadastro.
6.  **Decisão:** Se a distância for menor que **1.80**, o ponto é acesso ao aplicativo para marcação do ponto é liberado.

---

## 🛠️ Como Utilizar o Modelo (Exemplo Python)

```python
import tensorflow as tf
# Carregar o extrator de 128-D
model = tf.keras.models.load_model('geoponto_extractor_v8_3_1.keras')
# Predição gera o 'embedding' (RG digital do rosto)
embedding = model.predict(face_processada)
```

## 📂 Estrutura do Diretório

Além dos scripts principais, este módulo é organizado da seguinte forma:

*   **`fases_treinamento/`**: Armazena os modelos intermediários (`.keras`) de cada fase do projeto.
*   **`metricas_fases/`**: Contém os logs de treinamento, gráficos de acurácia e perda (loss) para auditoria acadêmica.
*   **`testeouro/`**: Conjunto de fotos curadas (desenvolvedores e figuras públicas) para validação real e testes de regressão.
*   **`venv/`**: Ambiente virtual com as dependências necessárias para rodar a IA.

---

## 📂 Guia de Arquivos e Scripts Python

Nesta seção, detalhamos a finalidade e como utilizar cada script Python presente no módulo de biometria para reprodução de testes e manutenção do modelo.

### 1. Preparação e Organização de Dados
*   **`organizar_celeba.py`**:
    *   **O que faz**: Lê o mapeamento de identidades e organiza as imagens brutas do dataset CelebA em pastas separadas por ID (identidade).
    *   **Como usar**: `python organizar_celeba.py`
*   **`filtrar_dataset.py`**:
    *   **O que faz**: Filtra o dataset já organizado, selecionando apenas identidades que possuem um número mínimo de amostras (ex: mais de 30 fotos por pessoa). Isso cria um dataset "otimizado" para o treinamento.
    *   **Como usar**: `python filtrar_dataset.py`

### 2. Validação e Testes de Modelo
*   **`comparar_faces.py`**:
    *   **O que faz**: Compara duas imagens específicas e calcula a Distância Euclidiana entre elas. Utiliza o threshold calibrado de **1.80** para determinar se as fotos pertencem à mesma pessoa.
    *   **Como usar**: `python comparar_faces.py caminho/da/foto1.jpg caminho/da/foto2.jpg`
*   **`validacao_real.py`**:
    *   **O que faz**: Script principal de teste com fotos da "vida real". Compara fotos dos desenvolvedores e figuras públicas para validar o modelo em cenários práticos.
    *   **Como usar**: `python validacao_real.py`
*   **`testar_matriz.py`**:
    *   **O que faz**: Executa uma bateria de testes cruzados (Matriz de Comparação) entre fotos de referência para validar se o modelo não está gerando falsos positivos ou falsos negativos.
    *   **Como usar**: `python testar_matriz.py`
*   **`teste_ouro_verificacao.py`**:
    *   **O que faz**: Ferramenta de validação acadêmica que utiliza um conjunto de teste isolado para gerar métricas de performance, como curvas de erro e precisão por classe.
    *   **Como usar**: `python teste_ouro_verificacao.py`

### 3. Deploy e Exportação
*   **`converter_para_tflite.py`**:
    *   **O que faz**: Converte o modelo extrator de alta performance (`.keras`) para o formato otimizado `.tflite`, permitindo sua execução em dispositivos móveis (Android/iOS) via Flutter.
    *   **Como usar**: `python converter_para_tflite.py`

### 4. Arquivos de Modelo
*   **`geoponto_extractor_v8_3_1.keras`**: Extrator final homologado de 128-D.
*   **`modelo_final_homologado.keras`**: Cópia de segurança do extrator em seu estágio de maior estabilidade.
*   **`modelo_classificacao.keras`**: Modelo completo (incluindo camadas de classificação) utilizado durante o treinamento.

---
**Desenvolvido para o Projeto Integrador - FATEC**
