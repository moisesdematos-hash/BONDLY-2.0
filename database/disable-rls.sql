-- Como escolhemos a Opção 1 (O backend NestJS gerencia o JWT e as senhas),
-- O backend precisa ter permissão para Inserir e Ler da tabela users.
-- Para MVP, vamos desabilitar temporariamente o RLS da tabela users, 
-- já que o backend que fara o papel de "guarda-costas".

ALTER TABLE users DISABLE ROW LEVEL SECURITY;
