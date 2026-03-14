# Bondly Backend 🚀

O motor de inteligência e persistência do Bondly, construído com **NestJS**.

## 🏗️ Arquitetura

O backend segue uma arquitetura modular, onde cada funcionalidade principal tem o seu próprio módulo:

- **Auth:** Gestão de autenticação via Supabase/JWT.
- **AI:** Integração com OpenAI para Coach e Insights.
- **Agreements:** Lógica para acordos e restrições do casal.
- **Checkins:** Gestão de humor e sentimentos diários.
- **Wishlists:** Listas de desejos partilhadas.
- **Relationships:** Gestão da ligação entre os parceiros.
- **Garden:** Lógica de gamificação e XP.

## 🛠️ Setup

1. **Instalar dependências:**
```bash
npm install
```

2. **Variáveis de Ambiente:**
Crie um ficheiro `.env` baseado no `.env.example`:
```env
SUPABASE_URL=
SUPABASE_KEY=
OPENAI_API_KEY=
STRIPE_SECRET_KEY=
```

3. **Execução:**
```bash
# desenvolvimento
npm run start:dev

# produção
npm run build
npm run start:prod
```

## 🧪 Base de Dados
O projeto utiliza o **Supabase**. Os scripts de inicialização e políticas de RLS encontram-se na pasta `../database`.

## 📄 Licença
Propriedade privada da Bondly Team.
