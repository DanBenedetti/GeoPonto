# GeoPonto - Sistema de Controle de Ponto por Geolocalização

Sistema de controle de ponto para funcionários, que utiliza geolocalização para registro e acompanhamento de jornada de trabalho. Este projeto está sendo desenvolvido como Trabalho de Conclusão de Curso (TCC) para a graduação de Desenvolvimento de Softwares Multiplataforma (DSM) da FATEC Franca.

## 💻 Tecnologias

* **Frontend:** Flutter
* **Backend:** Python
* **Banco de Dados:** PostgreSQL
* **Controle de Versão:** Git e GitHub

## 🚀 Funcionalidades

* Registro de ponto com base na geolocalização do usuário.
* Validação de presença dentro de um raio de 50 metros do local de trabalho.
* Cadastro e gerenciamento de usuários e empresas.
* Relatórios de horas trabalhadas e faltas.
* Autenticação e autorização de usuários.

## 📋 Modelagem de Casos de Uso

O diagrama abaixo descreve as principais interações entre os usuários (Funcionários e Empregadores) e o sistema GeoPonto.

```mermaid
flowchart LR
    F((Funcionário))
    E((Empregador))
    GPS[[Sistema GPS]]

    subgraph Sistema ["Sistema GeoPonto"]
        direction TB
        UC1([Fazer Login])
        UC2([Autenticar via Biometria facial])
        UC3([Registrar Ponto])
        UC4([Validar Geolocalização - Geofencing])
        UC5([Visualizar Histórico de Pontos])
        UC6([Gerenciar Funcionários])
        UC7([Configurar Localizações e Raio])
        UC8([Gerenciar Jornadas de Trabalho])
        UC9([Visualizar Dashboard de Analytics])
        UC10([Validar Ponto e Ocorrências])
    end

    F --- UC1
    F --- UC3
    F --- UC5

    E --- UC1
    E --- UC6
    E --- UC7
    E --- UC8
    E --- UC9
    E --- UC10

    UC1 -.->|include| UC2
    UC3 -.->|include| UC4
    UC4 --- GPS
```

### Detalhes dos Casos de Uso
*   **Autenticação de Dois Fatores (2FA):** O caso de uso "Fazer Login" inclui obrigatoriamente a "Autenticação via Biometria", garantindo a identidade do colaborador.
*   **Geofencing:** O "Registro de Ponto" depende da "Validação de Geolocalização", que consome dados em tempo real do GPS para confirmar se o funcionário está dentro do raio permitido.
*   **Gestão Administrativa:** O Empregador possui permissões exclusivas para configurar os parâmetros de controle (geocercas e jornadas) e analisar métricas de produtividade.

## 📋 Requisitos do Sistema

Para o cumprimento das metas do Projeto Integrador, o sistema foi delimitado pelos seguintes requisitos:

### Requisitos Funcionais (RF)
| ID | Descrição | Ator |
| :--- | :--- | :--- |
| **RF01** | Autenticação por Dois Fatores (2FA) via senha e biometria facial. | Funcionário |
| **RF02** | Registro de ponto com captura automática de coordenadas GPS. | Funcionário |
| **RF03** | Validação automática de Geofencing (raio permitido) para registro. | Sistema |
| **RF04** | Visualização de espelho de ponto e histórico de registros. | Funcionário |
| **RF05** | Gestão de funcionários, empresas e jornadas (Interface Web). | Empregador |
| **RF06** | Configuração de perímetros de trabalho e raios de tolerância (Interface Web). | Empregador |
| **RF07** | Validação e tratamento de ocorrências de ponto (Interface Web). | Empregador |
| **RF08** | Notificação de registros e pendências via serviço de mensageria. | Sistema |

### Requisitos Não Funcionais (RNF)
| ID | Descrição | Categoria |
| :--- | :--- | :--- |
| **RNF01** | Acurácia da biometria facial deve ser superior a 80%. | Segurança |
| **RNF02** | O extrator de características faciais deve ser treinado do zero (Weights=None). | Acadêmico |
| **RNF03** | Interface do funcionário deve ser Mobile (Android/iOS). | Portabilidade |
| **RNF04** | Interface do empregador deve ser Web (Browser). | Acessibilidade |
| **RNF05** | Tempo de inferência da biometria no App não deve exceder 3 segundos. | Performance |
| **RNF06** | Backend hospedado em nuvem (VM Azure) para alta disponibilidade. | Infraestrutura |
| **RNF07** | Uso de PostgreSQL para persistência de dados georreferenciados. | Robustez |

## 🛠️ Como Rodar o Projeto

**Pré-requisitos:**

Certifique-se de ter as seguintes ferramentas instaladas:

* [Python 3.8+](https://www.python.org/downloads/)
* [Flutter SDK](https://flutter.dev/docs/get-started/install)
* [pip](https://pip.pypa.io/en/stable/installing/)

**Instruções:**

1.  **Clone o repositório:**
    ```bash
    git clone [https://github.com/ThiagoResende88/GeoPonto_fatec.git](https://github.com/ThiagoResende88/GeoPonto_fatec.git)
    ```
2.  **Acesse a pasta do projeto:**
    ```bash
    cd GeoPonto_fatec
    ```
3.  **Configurar o Banco de Dados e Backend:**

    * A configuração do banco de dados (PostgreSQL) e do ambiente Python agora é automatizada via scripts no diretório `/backend`.
    * Consulte o README interno da pasta `backend` para instruções detalhadas sobre o `setup_vm.sh`.

4.  **Rodar a aplicação Backend (Python):**

    * Acesse a pasta do backend:
      ```bash
      cd backend
      ```
    * Instale as dependências:
      ```bash
      pip install -r requirements.txt
      ```
    * Inicie a aplicação:
      ```bash
      python main.py
      ```

5.  **Rodar a aplicação Frontend (Flutter):**

    * Acesse a pasta do frontend:
      ```bash
      cd ../frontend
      ```
    * Baixe as dependências:
      ```bash
      flutter pub get
      ```
    * Inicie a aplicação em um emulador ou dispositivo conectado:
      ```bash
      flutter run
      ```

6.  **Acessar a API:**

    * A API estará disponível em `********`.
    * Você pode usar uma ferramenta como o Postman ou Insomnia para testar os endpoints.
  
## 📂 Estrutura do Projeto

* `/backend`: Contém o código-fonte da API em Python.
* `/frontend`: Contém o código-fonte da interface do usuário em Flutter.
* `/docs`: Documentação adicional do projeto.
* `/scripts`: Scripts para automação (CI/CD, deploy, etc.).

## 👥 Equipe

👨‍💻 Danilo Benedette — Design e Frontend | [LinkedIn](https://www.linkedin.com/in/danilo-benedetti-98161436b) · [GitHub](https://github.com/DanBenedetti) 

👨‍💻 Gustavo Santos— FullStack | [LinkedIn](https://www.linkedin.com/in/gustavo-moreira-santos-628857243/) · [GitHub](https://github.com/GustavoMSantoss)

👨‍💻 Thiago Resende — DevOps, Backend e Documentação | 
[LinkedIn](https://www.linkedin.com/in/thiagodiasresende/) · [GitHub](https://github.com/ThiagoResende88) 

👨‍💻 Wilton Monteiro — QA e UX Geral | [LinkedIn](https://www.linkedin.com/in/wilton-monteiro-resende-415631287/) · [GitHub](https://github.com/Wilton-Monteiro)
