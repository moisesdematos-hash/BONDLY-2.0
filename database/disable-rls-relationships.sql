-- Desabilitamos o RLS na criação de relacionamentos 
-- O nosso backend valida quem pode fazer isso com os tokens JWT

ALTER TABLE relationships DISABLE ROW LEVEL SECURITY;
ALTER TABLE relationship_spaces DISABLE ROW LEVEL SECURITY;
