# Bondly Database (Supabase) 🗄️

Este diretório contém os esquemas SQL e scripts de inicialização para a base de dados PostgreSQL alojada no Supabase.

## 📄 Scripts Principais

- **[schema.sql](./schema.sql):** Estrutura inicial das tabelas núcleo (users, relationships, messages).
- **[seed_and_rls.sql](./seed_and_rls.sql):** O ficheiro mais importante. Contém:
    - Dados iniciais (Perguntas e Desafios).
    - Tabelas de extensões (Garden, Memories, Wishlists, Agreements).
    - **Políticas de RLS (Row Level Security):** Filtros de segurança que garantem que um casal só vê os dados da sua própria relação.

## 🔒 Segurança (RLS)

O Bondly utiliza RLS extensivamente. Todas as tabelas têm políticas que verificam se o `auth.uid()` pertence ao `relationship_id` da linha em questão através da tabela `relationship_spaces`.

## 🛠️ Como Aplicar Alterações

1. Aceda ao [Supabase SQL Editor](https://app.supabase.com/).
2. Copie o conteúdo dos scripts necessários.
3. Execute no editor para atualizar o esquema ou as políticas de segurança.

---
Propriedade privada da Bondly Team.
