-- Adiciona a coluna invite_code na tabela relationships
-- Ela é responsável por permitir que parceiros se conectem no app.

ALTER TABLE relationships ADD COLUMN invite_code TEXT;
CREATE INDEX idx_relationships_invite_code ON relationships(invite_code);
