<p align="center">
  <img src="assets/images/logo.png" alt="Logo Bizzu Concursos" width="180">
</p>

<h1 align="center">Bizzu Concursos 🚀</h1>

<p align="center">
  Aplicativo desenvolvido em Flutter para auxiliar na preparação para concursos públicos.
</p>

---

## 📖 Sobre o Projeto

O **Bizzu Concursos** é um aplicativo desenvolvido em **Flutter** com o objetivo de auxiliar usuários na preparação para concursos públicos.

O projeto possui integração com o **Firebase**, utilizando autenticação de usuários e armazenamento de dados através do **Cloud Firestore**.

O aplicativo está sendo desenvolvido como projeto acadêmico, aplicando conceitos de desenvolvimento mobile, arquitetura de software e integração com banco de dados em nuvem.

---

## ✨ Funcionalidades

Atualmente, o projeto conta com:

- 👤 Cadastro de usuários
- 🔐 Autenticação com Firebase
- ☁️ Armazenamento de dados no Cloud Firestore
- 📱 Interface desenvolvida em Flutter
- 🧭 Navegação entre telas
- 💾 Persistência dos dados dos usuários

---

## 🛠️ Tecnologias Utilizadas

As principais tecnologias utilizadas no projeto são:

- **Flutter**
- **Dart**
- **Firebase Authentication**
- **Cloud Firestore**
- **Android Studio / Android SDK**
- **Visual Studio Code**
- **Git e GitHub**

---

## 📋 Pré-requisitos

Antes de executar o projeto, certifique-se de possuir os seguintes itens instalados e configurados:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/)
- [Android Studio](https://developer.android.com/studio) ou [VS Code](https://code.visualstudio.com/)
- Extensões **Flutter** e **Dart** no VS Code
- Emulador Android configurado ou dispositivo físico conectado

Para verificar se o ambiente Flutter está configurado corretamente, execute:

```bash
flutter doctor
```

---

## 🚀 Instalação e Execução

Siga os passos abaixo para executar o projeto localmente.

### 1. Clonar o Repositório

Abra o terminal e clone o repositório para a sua máquina:

```bash
git clone <url-do-repositorio>
```

Após finalizar o download, acesse a pasta do projeto:

```bash
cd bizzu_concursos
```

---

### 2. Instalar as Dependências

Execute o comando abaixo para baixar todos os pacotes e dependências utilizados pelo projeto:

```bash
flutter pub get
```

---

### 3. 🔥 Configuração do Firebase (`google-services.json`)

Por motivos de segurança, o arquivo de configuração do Firebase **`google-services.json` não é enviado junto com o repositório público**.

Esse arquivo contém informações referentes à configuração do projeto no Firebase e está incluído no arquivo `.gitignore`, impedindo que ele seja enviado ao GitHub acidentalmente.

Para que o aplicativo consiga se conectar corretamente ao Firebase, siga os passos abaixo:

1. Solicite o arquivo **`google-services.json`** ao autor do projeto.

2. Após receber o arquivo, copie-o para a seguinte pasta:

   ```text
   bizzu_concursos/android/app/google-services.json
   ```

   A estrutura deverá ficar desta forma:

   ```text
   bizzu_concursos/
   └── android/
       └── app/
           └── google-services.json
   ```

3. Certifique-se de que o nome do arquivo permaneça exatamente:

   ```text
   google-services.json
   ```

4. Após adicionar o arquivo, execute no terminal:

   ```bash
   flutter pub get
   ```

> ⚠️ **Importante:** não remova o `google-services.json` do `.gitignore` e não envie esse arquivo para um repositório público.

Sem o arquivo `google-services.json` configurado corretamente, recursos que dependem do Firebase, como **autenticação de usuários e acesso ao Cloud Firestore**, poderão não funcionar.

---

### 4. Executar o Aplicativo

Com o emulador Android aberto ou um dispositivo físico conectado ao computador, execute:

```bash
flutter run
```

O Flutter irá compilar o projeto, instalar o aplicativo no dispositivo selecionado e iniciar sua execução.

---

## 📂 Estrutura do Projeto

A estrutura principal do projeto está organizada da seguinte maneira:

```text
bizzu_concursos/
│
├── android/
│
├── assets/
│   └── images/
│       └── logo.png
│
├── lib/
│   │
│   ├── controllers/
│   │   └── cadastro_controller.dart
│   │
│   ├── models/
│   │   └── usuario_model.dart
│   │
│   ├── views/
│   │   ├── bem_vindo_view.dart
│   │   └── cadastro_view.dart
│   │
│   └── main.dart
│
├── test/
├── web/
├── pubspec.yaml
└── README.md
```

---

## 🔥 Firebase

O **Firebase** é utilizado como serviço de backend da aplicação.

### 🔐 Firebase Authentication

Responsável pelo gerenciamento da autenticação dos usuários do aplicativo.

Ele permite identificar e controlar o acesso dos usuários aos recursos da aplicação.

### ☁️ Cloud Firestore

Utilizado como banco de dados em nuvem para armazenar e consultar as informações utilizadas pelo aplicativo.

Os dados ficam vinculados aos usuários autenticados através do Firebase.

---

## 🏗️ Organização do Projeto

O projeto foi organizado separando diferentes responsabilidades da aplicação.

### Models

Responsáveis pela representação e estrutura dos dados utilizados pelo aplicativo.

```text
lib/models/
```

### Views

Responsáveis pelas telas e interfaces apresentadas aos usuários.

```text
lib/views/
```

### Controllers

Responsáveis pela lógica da aplicação e pela comunicação entre as telas, os modelos e os serviços utilizados pelo sistema.

```text
lib/controllers/
```

Essa separação ajuda a manter o código mais organizado e facilita futuras manutenções e implementações.

---

## 📌 Status do Projeto

🚧 **Em desenvolvimento**

O projeto ainda está em desenvolvimento e novas funcionalidades e melhorias poderão ser adicionadas futuramente.

---

## 👨‍💻 Autor

Desenvolvido por **Thiago Soares Costa**.

Projeto desenvolvido para fins acadêmicos e de aprendizado em desenvolvimento mobile.