-- Daily Questions for Couples (PT)
INSERT INTO daily_questions (question_text, relationship_type, language) VALUES
('Qual é a sua lembrança favorita de nós dois ultimamente?', 'casal', 'pt'),
('O que você mais admira em mim quando estamos com outras pessoas?', 'casal', 'pt'),
('Qual pequena coisa eu faço que sempre faz você sorrir?', 'casal', 'pt'),
('Se pudéssemos viajar para qualquer lugar amanhã, para onde iríamos?', 'casal', 'pt'),
('O que "casa" significa para você quando pensa em nosso relacionamento?', 'casal', 'pt');

-- Daily Questions for Couples (EN)
INSERT INTO daily_questions (question_text, relationship_type, language) VALUES
('What is your favorite recent memory of us?', 'casal', 'en'),
('What do you admire most about me when we are with other people?', 'casal', 'en'),
('What small thing do I do that always makes you smile?', 'casal', 'en'),
('If we could travel anywhere tomorrow, where would we go?', 'casal', 'en'),
('What does "home" mean to you when you think about our relationship?', 'casal', 'en');

-- Daily Questions for Friends (PT)
INSERT INTO daily_questions (question_text, relationship_type, language) VALUES
('Qual é a melhor piada interna que nós temos?', 'amizade', 'pt'),
('O que você mais valoriza em nossa amizade?', 'amizade', 'pt');

-- Challenges
INSERT INTO challenges (title, description, points, premium_only) VALUES
('Bilhete de Gratidão', 'Escreva um pequeno bilhete físico ou digital expressando gratidão por algo que seu parceiro fez hoje.', 50, false),
('Cozinhar Juntos', 'Preparem uma refeição nova do zero sem usar aplicativos de entrega.', 100, false),
('Noite sem Telas', 'Passem 2 horas à noite sem usar celulares, tablets ou TV, focando apenas na conversa ou em um jogo.', 150, false),
('Elogio Sincero', 'Faça um elogio profundo e sincero sobre uma característica do seu parceiro que você raramente menciona.', 50, false),
('Piquenique na Sala', 'Transformem a sala de estar em um espaço de piquenique para o jantar.', 80, true);
