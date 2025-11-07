# GeoPonto - Frontend

Este é o repositório do frontend do aplicativo GeoPonto, desenvolvido com Flutter.

## 🚀 Visão Geral

O GeoPonto é um sistema de controle de ponto eletrônico que utiliza geolocalização para validar os registros de entrada e saída dos funcionários. O aplicativo foi projetado para ser intuitivo e fácil de usar, tanto para colaboradores quanto para empregadores.

## ✨ Funcionalidades Principais

*   **Autenticação:** Telas de login separadas para funcionários e empregadores.
*   **Registro de Ponto:** O funcionário pode bater o ponto com um único toque, e o sistema captura a geolocalização para validação.
*   **Espelho de Ponto:** Visualização do histórico de pontos batidos, agrupados por dia.
*   **Meu RH:** Uma central de autoatendimento para o funcionário, com atalhos para:
    *   Ocorrências de Ponto
    *   Meu Ponto
    *   Solicitações
    *   Espelho de Ponto
    *   Ajuste de Ponto
*   **Analytics:** O aplicativo coleta métricas de uso para ajudar a melhorar a experiência do usuário.

## 🛠️ Como Rodar o Projeto

1.  **Clone o Repositório:**
    ```bash
    git clone <URL_DO_REPOSITORIO>
    cd GeoPonto/frontend
    ```

2.  **Instale as Dependências:**
    Certifique-se de ter o Flutter SDK instalado.
    ```bash
    flutter pub get
    ```

3.  **Configure o Backend:**
    O frontend depende da API do backend para funcionar. Certifique-se de que o [servidor do backend](../backend/README.md) esteja rodando. A URL da API pode ser configurada no arquivo `lib/config/api_config.dart`.

4.  **Rode o Aplicativo:**
    ```bash
    flutter run
    ```

## 📂 Estrutura do Projeto

O projeto está organizado da seguinte forma:

*   `lib/`: Contém todo o código-fonte Dart.
    *   `main.dart`: O ponto de entrada da aplicação.
    *   `components/`: Widgets reutilizáveis (botões, campos de texto, etc.).
    *   `config/`: Arquivos de configuração, como a URL da API.
    *   `mixins/`: Classes Mixin para funcionalidades compartilhadas.
    *   `models/`: As classes de modelo que representam os dados da aplicação (Ponto, Funcionário, etc.).
    *   `navigation/`: Lógica de navegação e rotas.
    *   `screens/`: As diferentes telas da aplicação, organizadas por perfil (funcionário, empregador).
    *   `services/`: Serviços que lidam com a comunicação com a API e outras lógicas de negócio.
    *   `utils/`: Classes utilitárias.
*   `assets/`: Contém os assets da aplicação, como imagens e ícones.
*   `pubspec.yaml`: O arquivo de manifesto do projeto, que declara as dependências e outras configurações.

## 📦 Principais Dependências

*   `flutter_svg`: Para renderizar imagens SVG.
*   `http`: Para fazer requisições HTTP para a API.
*   `intl`: Para formatação de datas e números.
*   `geolocator`: Para obter a localização do dispositivo.
*   `flutter_map`: Para exibir mapas.
*   `geocoding`: Para converter coordenadas em endereços.
*   `month_picker_dialog`: Para selecionar o mês e o ano no espelho de ponto.
*   `shared_preferences`: Para armazenamento local de dados simples (como tokens de autenticação).
