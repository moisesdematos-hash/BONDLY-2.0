-- 1. SEED DATA

-- Daily Questions (Exemplos em Português)
INSERT INTO daily_questions (question_text, relationship_type, language) VALUES
('Quais são as três coisas que você mais aprecia no seu parceiro hoje?', 'casal', 'pt'),
('Qual é a sua lembrança favorita de nós dois juntos?', 'casal', 'pt'),
('Se pudéssemos viajar para qualquer lugar amanhã, para onde iríamos?', 'casal', 'pt'),
('O que faz você se sentir mais amado(a) por mim?', 'casal', 'pt'),
('Qual é um sonho que você ainda quer realizar este ano?', 'casal', 'pt'),
('Como posso ser um melhor amigo/parceiro para você esta semana?', 'casal', 'pt');

-- Challenges
INSERT INTO challenges (title, description, points, premium_only) VALUES
('Elogio Sincero', 'Faça um elogio inesperado sobre algo que seu parceiro realizou recentemente.', 10, false),
('Noite sem Telas', 'Passem uma noite inteira sem usar celulares ou TV, apenas conversando ou jogando.', 20, false),
('Cozinhando Juntos', 'Preparem uma refeição completa juntos do início ao fim.', 15, false),
('Passeio ao Ar Livre', 'Façam uma caminhada de pelo menos 30 minutos em um lugar que vocês gostem.', 10, false),
('Carta de Gratidão', 'Escreva uma pequena nota ou carta expressando por que você é grato pela outra pessoa.', 25, true);

-- 2. ROW LEVEL SECURITY (RLS) policies

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE relationships ENABLE ROW LEVEL SECURITY;
ALTER TABLE relationship_spaces ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE emotional_checkins ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenge_participation ENABLE ROW LEVEL SECURITY;

-- Users: apenas o próprio usuário pode ver seus dados
CREATE POLICY "Users can view own data" ON users FOR SELECT USING (auth.uid() = id);

-- Relationships: usuários vinculados via relationship_spaces podem ver a relação
CREATE POLICY "Users can view their relationships" ON relationships FOR SELECT 
USING (EXISTS (SELECT 1 FROM relationship_spaces WHERE relationship_id = id AND user_id = auth.uid()));

-- Relationship Spaces: usuários podem ver onde estão incluídos
CREATE POLICY "Users can view their spaces" ON relationship_spaces FOR SELECT 
USING (user_id = auth.uid());

-- Messages: usuários em um relacionamento podem ler as mensagens daquele relacionamento
CREATE POLICY "Users can read relationship messages" ON messages FOR SELECT
USING (EXISTS (SELECT 1 FROM relationship_spaces WHERE relationship_id = messages.relationship_id AND user_id = auth.uid()));

-- Messages: usuários podem enviar mensagens para seus relacionamentos
CREATE POLICY "Users can insert relationship messages" ON messages FOR INSERT
WITH CHECK (EXISTS (SELECT 1 FROM relationship_spaces WHERE relationship_id = messages.relationship_id AND user_id = auth.uid()));

-- Emotional Check-ins: o próprio usuário vê tudo, o parceiro vê apenas que existe (para status)
CREATE POLICY "Users can view own checkins" ON emotional_checkins FOR SELECT
USING (
  user_id = auth.uid() OR 
  EXISTS (SELECT 1 FROM relationship_spaces WHERE relationship_id = emotional_checkins.relationship_id AND user_id = auth.uid())
);


CREATE POLICY "Users can insert checkins" ON emotional_checkins FOR INSERT
WITH CHECK (user_id = auth.uid());

-- Daily Questions: todos os usuários autenticados podem ler
ALTER TABLE daily_questions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Everyone can read daily questions" ON daily_questions FOR SELECT TO authenticated USING (true);

-- Daily Answers: apenas usuários no relacionamento podem ver as respostas (após responderem tb)
CREATE POLICY "Users can view relationship answers" ON daily_answers FOR SELECT
USING (EXISTS (SELECT 1 FROM relationship_spaces WHERE relationship_id = daily_answers.relationship_id AND user_id = auth.uid()));

CREATE POLICY "Users can insert answers" ON daily_answers FOR INSERT
WITH CHECK (user_id = auth.uid());

-- 3. Garden Stats
CREATE TABLE IF NOT EXISTS garden_stats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  relationship_id UUID NOT NULL REFERENCES relationships(id) ON DELETE CASCADE,
  level INTEGER DEFAULT 1,
  xp INTEGER DEFAULT 0,
  health INTEGER DEFAULT 100,
  last_activity_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE garden_stats ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view relationship garden stats" ON garden_stats FOR SELECT
USING (EXISTS (SELECT 1 FROM relationship_spaces WHERE relationship_id = garden_stats.relationship_id AND user_id = auth.uid()));

-- 4. Memories (Mural de Memórias)
CREATE TABLE IF NOT EXISTS memories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  relationship_id UUID NOT NULL REFERENCES relationships(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  media_url TEXT NOT NULL,
  media_type VARCHAR(50) DEFAULT 'image',
  caption TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE memories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view relationship memories" ON memories FOR SELECT
USING (EXISTS (SELECT 1 FROM relationship_spaces WHERE relationship_id = memories.relationship_id AND user_id = auth.uid()));

CREATE POLICY "Users can insert relationship memories" ON memories FOR INSERT
WITH CHECK (EXISTS (SELECT 1 FROM relationship_spaces WHERE relationship_id = memories.relationship_id AND user_id = auth.uid()));

-- 5. Shared Wishlist
CREATE TABLE IF NOT EXISTS shared_wishlists (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  relationship_id UUID NOT NULL REFERENCES relationships(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  link_url TEXT,
  is_purchased BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE shared_wishlists ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view relationship wishlists" ON shared_wishlists FOR SELECT
USING (EXISTS (SELECT 1 FROM relationship_spaces WHERE relationship_id = shared_wishlists.relationship_id AND user_id = auth.uid()));

CREATE POLICY "Users can insert relationship wishlists" ON shared_wishlists FOR INSERT
WITH CHECK (EXISTS (SELECT 1 FROM relationship_spaces WHERE relationship_id = shared_wishlists.relationship_id AND user_id = auth.uid()));

CREATE POLICY "Users can update relationship wishlists (mark as purchased)" ON shared_wishlists FOR UPDATE
USING (EXISTS (SELECT 1 FROM relationship_spaces WHERE relationship_id = shared_wishlists.relationship_id AND user_id = auth.uid()));

CREATE POLICY "Users can delete own wishlists" ON shared_wishlists FOR DELETE
USING (user_id = auth.uid());
