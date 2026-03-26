-- =============================================
-- M.A.P.A. — COPSOQ II Database Structure
-- Execute no SQL Editor do Supabase Dashboard
-- =============================================

-- ============================================
-- 1. TABELA: departments (Setores)
-- ============================================
CREATE TABLE IF NOT EXISTS departments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id BIGINT REFERENCES empresas(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- 2. TABELA: employees (Colaboradores)
-- ============================================
CREATE TABLE IF NOT EXISTS employees (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  department_id UUID NOT NULL REFERENCES departments(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- 3. TABELA: categories (Categorias COPSOQ)
-- ============================================
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- 4. TABELA: questions (Perguntas)
-- ============================================
CREATE TABLE IF NOT EXISTS questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  question_number INTEGER NOT NULL UNIQUE,
  question_text TEXT NOT NULL,
  is_inverted BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- 5. TABELA: submissions (Envios)
-- ============================================
CREATE TABLE IF NOT EXISTS submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
  submitted_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- 6. TABELA: answers (Respostas)
-- ============================================
CREATE TABLE IF NOT EXISTS answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  submission_id UUID NOT NULL REFERENCES submissions(id) ON DELETE CASCADE,
  question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  score INTEGER NOT NULL CHECK (score >= 1 AND score <= 5),
  UNIQUE(submission_id, question_id)
);

-- ============================================
-- 7. ROW LEVEL SECURITY
-- ============================================
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE answers ENABLE ROW LEVEL SECURITY;

-- Permitir leitura publica de categorias e perguntas (necessario pro questionario)
CREATE POLICY "Qualquer um pode ler categories" ON categories FOR SELECT USING (true);
CREATE POLICY "Qualquer um pode ler questions" ON questions FOR SELECT USING (true);

-- Permitir leitura publica de departments (para selecao no questionario)
CREATE POLICY "Qualquer um pode ler departments" ON departments FOR SELECT USING (true);

-- Admins podem tudo
CREATE POLICY "Admins full departments" ON departments FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
);
CREATE POLICY "Admins full employees" ON employees FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
);
CREATE POLICY "Admins full categories" ON categories FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
);
CREATE POLICY "Admins full questions" ON questions FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
);
CREATE POLICY "Admins full submissions" ON submissions FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
);
CREATE POLICY "Admins full answers" ON answers FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
);

-- Anonimos podem inserir (questionario publico)
CREATE POLICY "Anon insere employees" ON employees FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "Anon insere submissions" ON submissions FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "Anon insere answers" ON answers FOR INSERT TO anon WITH CHECK (true);

-- Autenticados podem ler tudo (gestores veem dados)
CREATE POLICY "Auth le employees" ON employees FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Auth le submissions" ON submissions FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Auth le answers" ON answers FOR SELECT USING (auth.role() = 'authenticated');

-- ============================================
-- 8. SEED: Categorias do COPSOQ II (26 dimensoes)
-- ============================================
INSERT INTO categories (name) VALUES
  ('EXIGÊNCIAS QUANTITATIVAS'),
  ('RITMO DE TRABALHO'),
  ('EXIGÊNCIAS COGNITIVAS'),
  ('EXIGÊNCIAS EMOCIONAIS'),
  ('INFLUÊNCIA NO TRABALHO'),
  ('POSSIBILIDADES DE DESENVOLVIMENTO'),
  ('PREVISIBILIDADE'),
  ('TRANSPARÊNCIA DO PAPEL LABORAL'),
  ('RECOMPENSAS'),
  ('CONFLITOS LABORAIS'),
  ('APOIO SOCIAL DE COLEGAS'),
  ('APOIO SOCIAL DE SUPERIORES'),
  ('COMUNIDADE SOCIAL NO TRABALHO'),
  ('QUALIDADE DA LIDERANÇA'),
  ('CONFIANÇA HORIZONTAL'),
  ('CONFIANÇA VERTICAL'),
  ('JUSTIÇA E RESPEITO'),
  ('AUTO-EFICÁCIA'),
  ('SIGNIFICADO DO TRABALHO'),
  ('COMPROMISSO COM O LOCAL DE TRABALHO'),
  ('SATISFAÇÃO NO TRABALHO'),
  ('INSEGURANÇA LABORAL'),
  ('SAÚDE GERAL'),
  ('CONFLITO TRABALHO/FAMÍLIA'),
  ('PROBLEMAS EM DORMIR'),
  ('BURNOUT'),
  ('STRESS'),
  ('SINTOMAS DEPRESSIVOS'),
  ('COMPORTAMENTOS OFENSIVOS')
ON CONFLICT (name) DO NOTHING;

-- ============================================
-- 9. SEED: 76 Perguntas do COPSOQ II
-- Perguntas invertidas (is_inverted = true):
--   Onde "5 = Sempre" significa algo BOM
--   Ex: Influencia, Desenvolvimento, Recompensas, etc.
-- Perguntas normais (is_inverted = false):
--   Onde "5 = Sempre" significa algo RUIM
--   Ex: Exigencias, Burnout, Stress, etc.
-- ============================================

-- EXIGÊNCIAS QUANTITATIVAS (1-3) — normal
INSERT INTO questions (question_number, category_id, question_text, is_inverted) VALUES
(1,  (SELECT id FROM categories WHERE name = 'EXIGÊNCIAS QUANTITATIVAS'), 'A sua carga de trabalho acumula-se por ser mal distribuída?', false),
(2,  (SELECT id FROM categories WHERE name = 'EXIGÊNCIAS QUANTITATIVAS'), 'Com que frequência não tem tempo para completar todas as tarefas do seu trabalho?', false),
(3,  (SELECT id FROM categories WHERE name = 'EXIGÊNCIAS QUANTITATIVAS'), 'Precisa fazer horas-extra?', false),

-- RITMO DE TRABALHO (4) — normal
(4,  (SELECT id FROM categories WHERE name = 'RITMO DE TRABALHO'), 'Precisa trabalhar muito rapidamente?', false),

-- EXIGÊNCIAS COGNITIVAS (5-7) — normal
(5,  (SELECT id FROM categories WHERE name = 'EXIGÊNCIAS COGNITIVAS'), 'O seu trabalho exige a sua atenção constante?', false),
(6,  (SELECT id FROM categories WHERE name = 'EXIGÊNCIAS COGNITIVAS'), 'O seu trabalho requer que seja bom a propor novas ideias?', false),
(7,  (SELECT id FROM categories WHERE name = 'EXIGÊNCIAS COGNITIVAS'), 'O seu trabalho exige que tome decisões difíceis?', false),

-- EXIGÊNCIAS EMOCIONAIS (8) — normal
(8,  (SELECT id FROM categories WHERE name = 'EXIGÊNCIAS EMOCIONAIS'), 'O seu trabalho exige emocionalmente de si?', false),

-- INFLUÊNCIA NO TRABALHO (9-12) — invertida (mais = melhor)
(9,  (SELECT id FROM categories WHERE name = 'INFLUÊNCIA NO TRABALHO'), 'Tem um elevado grau de influência no seu trabalho?', true),
(10, (SELECT id FROM categories WHERE name = 'INFLUÊNCIA NO TRABALHO'), 'Participa na escolha das pessoas com quem trabalha?', true),
(11, (SELECT id FROM categories WHERE name = 'INFLUÊNCIA NO TRABALHO'), 'Pode influenciar a quantidade de trabalho que lhe compete a si?', true),
(12, (SELECT id FROM categories WHERE name = 'INFLUÊNCIA NO TRABALHO'), 'Tem alguma influência sobre o tipo de tarefas que faz?', true),

-- POSSIBILIDADES DE DESENVOLVIMENTO (13-15) — invertida
(13, (SELECT id FROM categories WHERE name = 'POSSIBILIDADES DE DESENVOLVIMENTO'), 'O seu trabalho exige que tenha iniciativa?', true),
(14, (SELECT id FROM categories WHERE name = 'POSSIBILIDADES DE DESENVOLVIMENTO'), 'O seu trabalho permite-lhe aprender coisas novas?', true),
(15, (SELECT id FROM categories WHERE name = 'POSSIBILIDADES DE DESENVOLVIMENTO'), 'O seu trabalho permite-lhe usar as suas habilidades ou perícias?', true),

-- PREVISIBILIDADE (16-17) — invertida
(16, (SELECT id FROM categories WHERE name = 'PREVISIBILIDADE'), 'No seu local de trabalho, é informado com antecedência sobre decisões importantes, mudanças ou planos para o futuro?', true),
(17, (SELECT id FROM categories WHERE name = 'PREVISIBILIDADE'), 'Recebe toda a informação de que necessita para fazer bem o seu trabalho?', true),

-- TRANSPARÊNCIA DO PAPEL LABORAL (18-20) — invertida
(18, (SELECT id FROM categories WHERE name = 'TRANSPARÊNCIA DO PAPEL LABORAL'), 'O seu trabalho apresenta objectivos claros?', true),
(19, (SELECT id FROM categories WHERE name = 'TRANSPARÊNCIA DO PAPEL LABORAL'), 'Sabe exactamente quais as suas responsabilidades?', true),
(20, (SELECT id FROM categories WHERE name = 'TRANSPARÊNCIA DO PAPEL LABORAL'), 'Sabe exactamente o que é esperado de si?', true),

-- RECOMPENSAS (21-23) — invertida
(21, (SELECT id FROM categories WHERE name = 'RECOMPENSAS'), 'O seu trabalho é reconhecido e apreciado pela gerência?', true),
(22, (SELECT id FROM categories WHERE name = 'RECOMPENSAS'), 'A gerência do seu local de trabalho respeita-o?', true),
(23, (SELECT id FROM categories WHERE name = 'RECOMPENSAS'), 'É tratado de forma justa no seu local de trabalho?', true),

-- CONFLITOS LABORAIS (24-26) — normal
(24, (SELECT id FROM categories WHERE name = 'CONFLITOS LABORAIS'), 'Faz coisas no seu trabalho que uns concordam mas outros não?', false),
(25, (SELECT id FROM categories WHERE name = 'CONFLITOS LABORAIS'), 'Por vezes tem que fazer coisas que deveriam ser feitas de outra maneira?', false),
(26, (SELECT id FROM categories WHERE name = 'CONFLITOS LABORAIS'), 'Por vezes tem que fazer coisas que considera desnecessárias?', false),

-- APOIO SOCIAL DE COLEGAS (27-29) — invertida
(27, (SELECT id FROM categories WHERE name = 'APOIO SOCIAL DE COLEGAS'), 'Com que frequência tem ajuda e apoio dos seus colegas de trabalho?', true),
(28, (SELECT id FROM categories WHERE name = 'APOIO SOCIAL DE COLEGAS'), 'Com que frequência os seus colegas estão dispostos a ouvi-lo(a) sobre os seus problemas de trabalho?', true),
(29, (SELECT id FROM categories WHERE name = 'APOIO SOCIAL DE COLEGAS'), 'Com que frequência os seus colegas falam consigo acerca do seu desempenho laboral?', true),

-- APOIO SOCIAL DE SUPERIORES (30-32) — invertida
(30, (SELECT id FROM categories WHERE name = 'APOIO SOCIAL DE SUPERIORES'), 'Com que frequência o seu superior imediato fala consigo sobre como está a decorrer o seu trabalho?', true),
(31, (SELECT id FROM categories WHERE name = 'APOIO SOCIAL DE SUPERIORES'), 'Com que frequência tem ajuda e apoio do seu superior imediato?', true),
(32, (SELECT id FROM categories WHERE name = 'APOIO SOCIAL DE SUPERIORES'), 'Com que frequência é que o seu superior imediato fala consigo em relação ao seu desempenho laboral?', true),

-- COMUNIDADE SOCIAL NO TRABALHO (33-35) — invertida
(33, (SELECT id FROM categories WHERE name = 'COMUNIDADE SOCIAL NO TRABALHO'), 'Existe um bom ambiente de trabalho entre si e os seus colegas?', true),
(34, (SELECT id FROM categories WHERE name = 'COMUNIDADE SOCIAL NO TRABALHO'), 'Existe uma boa cooperação entre os colegas de trabalho?', true),
(35, (SELECT id FROM categories WHERE name = 'COMUNIDADE SOCIAL NO TRABALHO'), 'No seu local de trabalho sente-se parte de uma comunidade?', true),

-- QUALIDADE DA LIDERANÇA (36-39) — invertida
(36, (SELECT id FROM categories WHERE name = 'QUALIDADE DA LIDERANÇA'), 'Oferece aos indivíduos e ao grupo boas oportunidades de desenvolvimento?', true),
(37, (SELECT id FROM categories WHERE name = 'QUALIDADE DA LIDERANÇA'), 'Dá prioridade à satisfação no trabalho?', true),
(38, (SELECT id FROM categories WHERE name = 'QUALIDADE DA LIDERANÇA'), 'É bom no planeamento do trabalho?', true),
(39, (SELECT id FROM categories WHERE name = 'QUALIDADE DA LIDERANÇA'), 'É bom a resolver conflitos?', true),

-- CONFIANÇA HORIZONTAL (40-42) — mista
(40, (SELECT id FROM categories WHERE name = 'CONFIANÇA HORIZONTAL'), 'Os funcionários ocultam informações uns dos outros?', false),
(41, (SELECT id FROM categories WHERE name = 'CONFIANÇA HORIZONTAL'), 'Os funcionários ocultam informação à gerência?', false),
(42, (SELECT id FROM categories WHERE name = 'CONFIANÇA HORIZONTAL'), 'Os funcionários confiam uns nos outros de um modo geral?', true),

-- CONFIANÇA VERTICAL (43-45) — mista
(43, (SELECT id FROM categories WHERE name = 'CONFIANÇA VERTICAL'), 'A gerência confia nos seus funcionários para fazerem o seu trabalho bem?', true),
(44, (SELECT id FROM categories WHERE name = 'CONFIANÇA VERTICAL'), 'Confia na informação que lhe é transmitida pela gerência?', true),
(45, (SELECT id FROM categories WHERE name = 'CONFIANÇA VERTICAL'), 'A gerência oculta informação aos seus funcionários?', false),

-- JUSTIÇA E RESPEITO (46-48) — invertida
(46, (SELECT id FROM categories WHERE name = 'JUSTIÇA E RESPEITO'), 'Os conflitos são resolvidos de uma forma justa?', true),
(47, (SELECT id FROM categories WHERE name = 'JUSTIÇA E RESPEITO'), 'As sugestões dos funcionários são tratadas de forma séria pela gerência?', true),
(48, (SELECT id FROM categories WHERE name = 'JUSTIÇA E RESPEITO'), 'O trabalho é igualmente distribuído pelos funcionários?', true),

-- AUTO-EFICÁCIA (49-50) — invertida
(49, (SELECT id FROM categories WHERE name = 'AUTO-EFICÁCIA'), 'Sou sempre capaz de resolver problemas, se tentar o suficiente.', true),
(50, (SELECT id FROM categories WHERE name = 'AUTO-EFICÁCIA'), 'É-me fácil seguir os meus planos e atingir os meus objectivos.', true),

-- SIGNIFICADO DO TRABALHO (51-53) — invertida
(51, (SELECT id FROM categories WHERE name = 'SIGNIFICADO DO TRABALHO'), 'O seu trabalho tem algum significado para si?', true),
(52, (SELECT id FROM categories WHERE name = 'SIGNIFICADO DO TRABALHO'), 'Sente que o seu trabalho é importante?', true),
(53, (SELECT id FROM categories WHERE name = 'SIGNIFICADO DO TRABALHO'), 'Sente-se motivado e envolvido com o seu trabalho?', true),

-- COMPROMISSO COM O LOCAL DE TRABALHO (54-55) — invertida
(54, (SELECT id FROM categories WHERE name = 'COMPROMISSO COM O LOCAL DE TRABALHO'), 'Gosta de falar com os outros sobre o seu local de trabalho?', true),
(55, (SELECT id FROM categories WHERE name = 'COMPROMISSO COM O LOCAL DE TRABALHO'), 'Sente que os problemas do seu local de trabalho são seus também?', true),

-- SATISFAÇÃO NO TRABALHO (56-59) — invertida
(56, (SELECT id FROM categories WHERE name = 'SATISFAÇÃO NO TRABALHO'), 'As suas perspectivas de trabalho?', true),
(57, (SELECT id FROM categories WHERE name = 'SATISFAÇÃO NO TRABALHO'), 'As condições físicas do seu local de trabalho?', true),
(58, (SELECT id FROM categories WHERE name = 'SATISFAÇÃO NO TRABALHO'), 'A forma como as suas capacidades são utilizadas?', true),
(59, (SELECT id FROM categories WHERE name = 'SATISFAÇÃO NO TRABALHO'), 'O seu trabalho de uma forma global?', true),

-- INSEGURANÇA LABORAL (60) — normal
(60, (SELECT id FROM categories WHERE name = 'INSEGURANÇA LABORAL'), 'Sente-se preocupado em ficar desempregado?', false),

-- SAÚDE GERAL (61) — invertida (mais saude = melhor)
(61, (SELECT id FROM categories WHERE name = 'SAÚDE GERAL'), 'Em geral, sente que a sua saúde é:', true),

-- CONFLITO TRABALHO/FAMÍLIA (62-64) — normal
(62, (SELECT id FROM categories WHERE name = 'CONFLITO TRABALHO/FAMÍLIA'), 'Sente que o seu trabalho lhe exige muita energia que acaba por afectar a sua vida privada negativamente?', false),
(63, (SELECT id FROM categories WHERE name = 'CONFLITO TRABALHO/FAMÍLIA'), 'Sente que o seu trabalho lhe exige muito tempo que acaba por afectar a sua vida privada negativamente?', false),
(64, (SELECT id FROM categories WHERE name = 'CONFLITO TRABALHO/FAMÍLIA'), 'A sua família e os seus amigos dizem-lhe que trabalha demais?', false),

-- PROBLEMAS EM DORMIR (65-66) — normal
(65, (SELECT id FROM categories WHERE name = 'PROBLEMAS EM DORMIR'), 'Dificuldade a adormecer?', false),
(66, (SELECT id FROM categories WHERE name = 'PROBLEMAS EM DORMIR'), 'Acordou várias vezes durante a noite e depois não conseguia adormecer novamente?', false),

-- BURNOUT (67-68) — normal
(67, (SELECT id FROM categories WHERE name = 'BURNOUT'), 'Fisicamente exausto?', false),
(68, (SELECT id FROM categories WHERE name = 'BURNOUT'), 'Emocionalmente exausto?', false),

-- STRESS (69-70) — normal
(69, (SELECT id FROM categories WHERE name = 'STRESS'), 'Irritado?', false),
(70, (SELECT id FROM categories WHERE name = 'STRESS'), 'Ansioso?', false),

-- SINTOMAS DEPRESSIVOS (71-72) — normal
(71, (SELECT id FROM categories WHERE name = 'SINTOMAS DEPRESSIVOS'), 'Triste?', false),
(72, (SELECT id FROM categories WHERE name = 'SINTOMAS DEPRESSIVOS'), 'Falta de interesse por coisas quotidianas?', false),

-- COMPORTAMENTOS OFENSIVOS (73-76) — normal
(73, (SELECT id FROM categories WHERE name = 'COMPORTAMENTOS OFENSIVOS'), 'Tem sido alvo de insultos ou provocações verbais?', false),
(74, (SELECT id FROM categories WHERE name = 'COMPORTAMENTOS OFENSIVOS'), 'Tem sido exposto a assédio sexual indesejado?', false),
(75, (SELECT id FROM categories WHERE name = 'COMPORTAMENTOS OFENSIVOS'), 'Tem sido exposto a ameaças de violência?', false),
(76, (SELECT id FROM categories WHERE name = 'COMPORTAMENTOS OFENSIVOS'), 'Tem sido exposto a violência física?', false)

ON CONFLICT (question_number) DO NOTHING;

-- ============================================
-- 10. VIEW: vw_respostas_completas
-- Cruzamento completo de dados com conversao
-- de escala 1-5 para 0-100
-- ============================================
CREATE OR REPLACE VIEW vw_respostas_completas AS
SELECT
  -- Identificacao
  e.id          AS employee_id,
  e.name        AS employee_name,
  d.id          AS department_id,
  d.name        AS department_name,

  -- Envio
  s.id          AS submission_id,
  s.submitted_at,

  -- Pergunta
  q.question_number,
  q.question_text,
  q.is_inverted,

  -- Categoria
  c.id          AS category_id,
  c.name        AS category_name,

  -- Nota original (1-5)
  a.score       AS score_original,

  -- Nota convertida para escala 0-100
  -- Formula: ((score - 1) / 4) * 100
  -- Para perguntas normais: 1=0, 2=25, 3=50, 4=75, 5=100 (mais alto = pior)
  -- Para perguntas invertidas: 5=0, 4=25, 3=50, 2=75, 1=100 (invertemos o score)
  CASE
    WHEN q.is_inverted = false THEN ROUND(((a.score - 1)::NUMERIC / 4) * 100)
    WHEN q.is_inverted = true  THEN ROUND(((5 - a.score)::NUMERIC / 4) * 100)
  END AS score_0_100,

  -- Nivel de risco baseado no score convertido
  CASE
    WHEN q.is_inverted = false AND ROUND(((a.score - 1)::NUMERIC / 4) * 100) <= 33 THEN 'Verde'
    WHEN q.is_inverted = false AND ROUND(((a.score - 1)::NUMERIC / 4) * 100) <= 66 THEN 'Amarelo'
    WHEN q.is_inverted = false THEN 'Vermelho'
    WHEN q.is_inverted = true  AND ROUND(((5 - a.score)::NUMERIC / 4) * 100) <= 33 THEN 'Verde'
    WHEN q.is_inverted = true  AND ROUND(((5 - a.score)::NUMERIC / 4) * 100) <= 66 THEN 'Amarelo'
    ELSE 'Vermelho'
  END AS nivel_risco

FROM answers a
  JOIN submissions s ON a.submission_id = s.id
  JOIN employees e   ON s.employee_id = e.id
  JOIN departments d ON e.department_id = d.id
  JOIN questions q   ON a.question_id = q.id
  JOIN categories c  ON q.category_id = c.id;

-- ============================================
-- 11. VIEW: vw_media_por_categoria_setor
-- Media por categoria e setor (para dashboard)
-- ============================================
CREATE OR REPLACE VIEW vw_media_por_categoria_setor AS
SELECT
  d.id   AS department_id,
  d.name AS department_name,
  c.id   AS category_id,
  c.name AS category_name,

  -- Media do score 0-100 por categoria/setor
  ROUND(AVG(
    CASE
      WHEN q.is_inverted = false THEN ((a.score - 1)::NUMERIC / 4) * 100
      WHEN q.is_inverted = true  THEN ((5 - a.score)::NUMERIC / 4) * 100
    END
  ), 1) AS score_medio,

  -- Nivel de risco da media
  CASE
    WHEN ROUND(AVG(
      CASE
        WHEN q.is_inverted = false THEN ((a.score - 1)::NUMERIC / 4) * 100
        WHEN q.is_inverted = true  THEN ((5 - a.score)::NUMERIC / 4) * 100
      END
    ), 1) <= 33 THEN 'Verde'
    WHEN ROUND(AVG(
      CASE
        WHEN q.is_inverted = false THEN ((a.score - 1)::NUMERIC / 4) * 100
        WHEN q.is_inverted = true  THEN ((5 - a.score)::NUMERIC / 4) * 100
      END
    ), 1) <= 66 THEN 'Amarelo'
    ELSE 'Vermelho'
  END AS nivel_risco,

  COUNT(DISTINCT s.id) AS total_submissions,
  COUNT(a.id)          AS total_answers

FROM answers a
  JOIN submissions s ON a.submission_id = s.id
  JOIN employees e   ON s.employee_id = e.id
  JOIN departments d ON e.department_id = d.id
  JOIN questions q   ON a.question_id = q.id
  JOIN categories c  ON q.category_id = c.id
GROUP BY d.id, d.name, c.id, c.name;
