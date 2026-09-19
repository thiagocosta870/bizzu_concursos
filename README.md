<p align="center">
  <img src="assets/images/logo.png" alt="Logo Bizzu Concursos" width="180">
</p>

<h1 align="center">Bizzu Concursos 🚀</h1>

<p align="center">
  O aliado definitivo para concurseiros. Organização de editais, controle de estudos e métricas de desempenho na palma da mão.
</p>

---

## 📖 Sobre o Projeto

O **Bizzu Concursos** é um aplicativo mobile desenvolvido em **Flutter** como Trabalho de Conclusão de Curso (TCC). Seu objetivo é resolver a desorganização no estudo para concursos públicos, centralizando métricas, cronogramas e conteúdos em uma única plataforma automatizada.

Diferente de planilhas manuais, o Bizzu oferece importação inteligente de editais através de uma **API própria** e um sistema nativo de rastreamento de foco de estudos, tudo suportado por uma infraestrutura robusta na nuvem.

---

## ✨ Funcionalidades Principais

- **Autenticação Segura:** Login via E-mail, Google e Facebook utilizando o Padrão Strategy.
- **Importação Automatizada:** Leitura e salvamento de editais de concursos reais em apenas 1 clique através de API externa.
- **Cronômetro Reativo:** Timer de estudos inteligente que utiliza canais nativos do SO para identificar perda de foco, distinguindo minimização intencional de desligamento automático da tela.
- **Dashboard Analítico:** Gráficos interativos (Pie e Bar Charts) gerados em tempo real com o progresso de cada edital, foco por matéria e produtividade semanal.
- **CRUD Completo:** Criação, leitura, atualização e exclusão de matérias e sessões de estudo personalizadas.

---

## 🏗️ Arquitetura e Organização

O projeto foi construído seguindo rigorosos padrões de engenharia de software para garantir escalabilidade e manutenção:

- **Arquitetura Base:** MVVM / MVC (Models, Views e Controllers).
- **Gerência de Estado:** Reatividade pontual utilizando `ChangeNotifier` e `StreamBuilder` para evitar reconstruções globais de tela (melhoria de performance e bateria).
- **Padrão Repository:** Isolamento total da comunicação com o banco de dados e APIs externas na camada de repositório (`HistoricoRepository`, `RevisaoRepository`).

---

## 🛠️ Tecnologias Utilizadas

**Frontend (Mobile)**

- **Flutter / Dart**
- **Fl_Chart** (Renderização de gráficos analíticos)
- **Screen State** (Monitoramento de hardware de tela)

**Backend e Nuvem**

- **Firebase Firestore** (Banco de Dados NoSQL em tempo real)
- **Firebase Authentication** (Gestão de Identidade)
- **Firebase Analytics** (Mapeamento de eventos)
- **Node.js & Vercel** (API externa construída especificamente para centralização e envio dos editais para o aplicativo mobile)

---

## 📂 Estrutura do Projeto

Abaixo, a organização estrutural das pastas do projeto:

```text
bizzu_concursos/
│
├── assets/images/          # Logos e recursos visuais
├── lib/
│   ├── controllers/        # Lógica de negócio e gerência de estado
│   ├── models/             # Classes de tipagem de dados
│   │   └── repositories/   # Conexões com Firestore e APIs
│   ├── strategies/         # Padrões de projeto (Ex: AuthStrategy)
│   ├── theme/              # Centralização de cores e tipografias (AppCores)
│   ├── utils/              # Serviços de uso geral e alertas
│   └── views/              # Telas (UI) e Componentes Customizados (Widgets)
│
└── pubspec.yaml
```
