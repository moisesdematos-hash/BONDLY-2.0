# Bondly Frontend 📱✨

A aplicação móvel do Bondly, construída com **Flutter** para proporcionar uma experiência emocional e premium aos casais.

## 🏗️ Estrutura de Pastas

Organizado por "features" para escalabilidade:

- **auth:** Login, registo e gestão de convites.
- **dashboard:** O ecrã central da experiência.
- **chat:** Conversa em tempo real com análise de sentimentos e SOS Icebreakers.
- **agreements:** Propostas e aceitação de regras do casal.
- **checkin:** Registo diário de humor.
- **memory_wall:** Mural de fotos, áudios e vídeos.
- **garden:** Visualização do jardim evolutivo 3D.
- **premium:** Funcionalidades de IA (Coach e Insights) e subscrições.

## 🛠️ Tecnologias Principais

- **Riverpod:** Gestão de estado reativa e segura.
- **Supabase Flutter:** Sincronização de dados e auth.
- **Framer-style Animations:** Micro-interações para um toque premium.
- **fl_chart:** Visualização de dados emocionais.

## 🚀 Como Executar

1. **Obter dependências:**
```bash
flutter pub get
```

2. **Configuração:**
Verifique se as credenciais do Supabase no `api_client.dart` ou `main.dart` estão corretas.

3. **Correr:**
```bash
flutter run
```

---
Propriedade privada da Bondly Team.
