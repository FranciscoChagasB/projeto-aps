# Projeto de Acompanhamento Terapêutico (APS) 
# *EM CONSTRUÇÃO*

Uma plataforma full-stack (Spring Boot + Flutter) projetada para facilitar a comunicação e o acompanhamento de planos de atividades terapêuticas para crianças, conectando pais/responsáveis e profissionais de saúde.

---

## ✨ Funcionalidades

O sistema é dividido em três perfis de usuário, cada um com suas próprias funcionalidades:

### 👤 **Responsável (Pai/Mãe)**
-   **Gerenciamento de Crianças:**
    -   Cadastro completo de filhos, incluindo foto de perfil e anexo de laudo (PDF).
    -   Edição e exclusão de perfis de crianças.
-   **Acompanhamento Terapêutico:**
    -   Visualização de planos de atividades criados por profissionais.
    -   Registro diário da execução de atividades (com status e observações).
    -   Visualização do feedback deixado pelos terapeutas.
-   **Conexão com Profissionais:**
    -   Vínculo seguro com profissionais de saúde através de código único ou QR Code.
    -   Visualização dos terapeutas que acompanham cada criança.

### 🩺 **Profissional de Saúde (Terapeuta)**
-   **Gerenciamento de Pacientes:**
    -   Dashboard com a lista de todas as crianças (pacientes) que acompanha.
    -   Visualização dos detalhes e planos de cada paciente.
-   **Biblioteca de Atividades:**
    -   CRUD completo para criar uma biblioteca pessoal e reutilizável de atividades.
-   **Planos de Atividades:**
    -   Criação de planos de atividades personalizados para cada criança.
    -   Gerenciamento dinâmico dos planos (adicionar/remover atividades, editar nome/objetivo, excluir plano).
-   **Compartilhamento de Código:**
    -   Geração de um código profissional único (texto e QR Code) para compartilhar com os responsáveis.

### 🔒 **Administrador**
-   **Gerenciamento de Usuários:**
    -   Dashboard com a lista de todos os usuários do sistema.
    -   Painel de filtros para buscar usuários por nome, email, CPF ou status.
    -   CRUD completo para gerenciar usuários (criar, editar dados e perfil, ativar/desativar e excluir).

---

## 🛠️ Tecnologias Utilizadas

### **Backend (API REST)**
-   **Framework:** Spring Boot 3
-   **Linguagem:** Java 21
-   **Segurança:** Spring Security com autenticação baseada em Token JWT.
-   **Banco de Dados:** Spring Data JPA / Hibernate.
-   **Validação:** Spring Validation.
-   **Dependências:** Lombok, Auth0 JWT.

### **Frontend (Aplicativo Multiplataforma)**
-   **Framework:** Flutter 3
-   **Linguagem:** Dart
-   **Gerenciamento de Estado:** Provider
-   **Comunicação HTTP:** Dio (com Interceptors para JWT)
-   **Pacotes Principais:**
    -   `image_picker`: Para seleção de fotos.
    -   `file_picker`: Para seleção de arquivos (PDF).
    -   `qr_flutter` & `mobile_scanner`: Para geração e leitura de QR Codes.
    -   `intl`: Para formatação de datas.
    -   `shared_preferences`: Para armazenamento local do token.

---

## 🚀 Como Executar o Projeto

### **Pré-requisitos**
-   Java JDK 21 ou superior.
-   Maven 3.8 ou superior.
-   Flutter SDK 3.x.x.
-   Uma IDE de sua preferência (IntelliJ IDEA, VS Code).
-   Um emulador Android/iOS ou um navegador (Chrome) para rodar o app Flutter.

### **1. Configurando o Backend**
```bash
# 1. Clone o repositório
git clone <url-do-seu-repositorio>

# 2. Navegue para a pasta do backend
cd projeto-aps-back

# 3. Configure o application.properties
#    Certifique-se de que as configurações do banco de dados e a chave secreta do JWT
#    estão corretas no arquivo `src/main/resources/application.properties`.
#
#    Exemplo:
#    spring.datasource.url=jdbc:postgresql://localhost:5432/seu_banco
#    spring.datasource.username=seu_usuario
#    spring.datasource.password=sua_senha
#    
#    api.security.token.secret=sua-chave-secreta-muito-forte

# 4. Compile e execute o projeto com Maven
./mvnw spring-boot:run
```
O servidor estará rodando em `http://localhost:8080`.

### **2. Configurando o Frontend**
```bash
# 1. Navegue para a pasta do frontend
cd ../projeto_aps_front

# 2. Instale as dependências do Flutter
flutter pub get

# 3. Configure a URL da API
#    Abra o arquivo `lib/services/api_client.dart` e verifique se a `baseUrl`
#    está correta para se comunicar com seu backend.
#    O padrão `http://10.0.2.2:8080/api` é para o emulador Android.
#    Se estiver rodando na web, use `http://localhost:8080/api`.

# 4. Execute o aplicativo
flutter run
```

---

## 📁 Estrutura do Projeto

### **Backend**
A estrutura segue o padrão de projetos do Spring Boot, com uma arquitetura em camadas bem definida:
-   `src/main/java/br/edu/ifce/projetoapsback`
    -   `config/`: Configurações de segurança e CORS.
    -   `model/`: Entidades JPA e DTOs (request/response).
    -   `repository/`: Interfaces do Spring Data JPA.
    -   `resource/`: Controllers da API REST.
    -   `security/`: Filtros e implementações do Spring Security.
    -   `service/`: Lógica de negócio da aplicação.

### **Frontend**
A estrutura do Flutter foi organizada para promover a separação de responsabilidades:
-   `lib/`
    -   `services/`: Classes responsáveis pela comunicação com a API (antiga `api/`).
    -   `models/`: Modelos de dados Dart que espelham os DTOs do backend.
    -   `providers/`: Gerenciadores de estado (lógica de negócio).
    -   `screens/`: As telas da aplicação, organizadas por perfil de usuário.
    -   `widgets/`: Widgets reutilizáveis em várias telas.

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor, siga os padrões de código e commit estabelecidos no projeto.

1.  Faça um Fork do projeto.
2.  Crie uma nova branch (`git checkout -b feature/sua-feature`).
3.  Faça o commit de suas mudanças (`git commit -m 'feat(escopo): Adiciona sua feature'`).
4.  Faça o Push para a branch (`git push origin feature/sua-feature`).
5.  Abra um Pull Request.

---

**Desenvolvido por Francisco Chagas** - *Outubro de 2025*
