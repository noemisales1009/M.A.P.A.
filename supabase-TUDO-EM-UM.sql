-- =============================================
-- M.A.P.A. — SCRIPT COMPLETO (TUDO EM UM)
-- Cole inteiro no SQL Editor do Supabase e clique Run
-- =============================================


-- ██████████████████████████████████████████████
-- PARTE 1: TABELAS COPSOQ
-- ██████████████████████████████████████████████

CREATE TABLE IF NOT EXISTS departments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS employees (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  department_id UUID NOT NULL REFERENCES departments(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  question_number INTEGER NOT NULL UNIQUE,
  question_text TEXT NOT NULL,
  is_inverted BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
  submitted_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  submission_id UUID NOT NULL REFERENCES submissions(id) ON DELETE CASCADE,
  question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  score INTEGER NOT NULL CHECK (score >= 1 AND score <= 5),
  UNIQUE(submission_id, question_id)
);

-- RLS
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE answers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Qualquer um pode ler categories" ON categories FOR SELECT USING (true);
CREATE POLICY "Qualquer um pode ler questions" ON questions FOR SELECT USING (true);
CREATE POLICY "Qualquer um pode ler departments" ON departments FOR SELECT USING (true);
CREATE POLICY "Admins full departments" ON departments FOR ALL USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin'));
CREATE POLICY "Admins full employees" ON employees FOR ALL USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin'));
CREATE POLICY "Admins full categories" ON categories FOR ALL USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin'));
CREATE POLICY "Admins full questions" ON questions FOR ALL USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin'));
CREATE POLICY "Admins full submissions" ON submissions FOR ALL USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin'));
CREATE POLICY "Admins full answers" ON answers FOR ALL USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin'));
CREATE POLICY "Anon insere employees" ON employees FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "Anon insere submissions" ON submissions FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "Anon insere answers" ON answers FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "Auth le employees" ON employees FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Auth le submissions" ON submissions FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Auth le answers" ON answers FOR SELECT USING (auth.role() = 'authenticated');

-- 29 Categorias COPSOQ
INSERT INTO categories (name) VALUES
  ('EXIGÊNCIAS QUANTITATIVAS'),('RITMO DE TRABALHO'),('EXIGÊNCIAS COGNITIVAS'),('EXIGÊNCIAS EMOCIONAIS'),
  ('INFLUÊNCIA NO TRABALHO'),('POSSIBILIDADES DE DESENVOLVIMENTO'),('PREVISIBILIDADE'),
  ('TRANSPARÊNCIA DO PAPEL LABORAL'),('RECOMPENSAS'),('CONFLITOS LABORAIS'),
  ('APOIO SOCIAL DE COLEGAS'),('APOIO SOCIAL DE SUPERIORES'),('COMUNIDADE SOCIAL NO TRABALHO'),
  ('QUALIDADE DA LIDERANÇA'),('CONFIANÇA HORIZONTAL'),('CONFIANÇA VERTICAL'),
  ('JUSTIÇA E RESPEITO'),('AUTO-EFICÁCIA'),('SIGNIFICADO DO TRABALHO'),
  ('COMPROMISSO COM O LOCAL DE TRABALHO'),('SATISFAÇÃO NO TRABALHO'),('INSEGURANÇA LABORAL'),
  ('SAÚDE GERAL'),('CONFLITO TRABALHO/FAMÍLIA'),('PROBLEMAS EM DORMIR'),
  ('BURNOUT'),('STRESS'),('SINTOMAS DEPRESSIVOS'),('COMPORTAMENTOS OFENSIVOS')
ON CONFLICT (name) DO NOTHING;

-- 76 Perguntas
INSERT INTO questions (question_number, category_id, question_text, is_inverted) VALUES
(1,(SELECT id FROM categories WHERE name='EXIGÊNCIAS QUANTITATIVAS'),'A sua carga de trabalho acumula-se por ser mal distribuída?',false),
(2,(SELECT id FROM categories WHERE name='EXIGÊNCIAS QUANTITATIVAS'),'Com que frequência não tem tempo para completar todas as tarefas do seu trabalho?',false),
(3,(SELECT id FROM categories WHERE name='EXIGÊNCIAS QUANTITATIVAS'),'Precisa fazer horas-extra?',false),
(4,(SELECT id FROM categories WHERE name='RITMO DE TRABALHO'),'Precisa trabalhar muito rapidamente?',false),
(5,(SELECT id FROM categories WHERE name='EXIGÊNCIAS COGNITIVAS'),'O seu trabalho exige a sua atenção constante?',false),
(6,(SELECT id FROM categories WHERE name='EXIGÊNCIAS COGNITIVAS'),'O seu trabalho requer que seja bom a propor novas ideias?',false),
(7,(SELECT id FROM categories WHERE name='EXIGÊNCIAS COGNITIVAS'),'O seu trabalho exige que tome decisões difíceis?',false),
(8,(SELECT id FROM categories WHERE name='EXIGÊNCIAS EMOCIONAIS'),'O seu trabalho exige emocionalmente de si?',false),
(9,(SELECT id FROM categories WHERE name='INFLUÊNCIA NO TRABALHO'),'Tem um elevado grau de influência no seu trabalho?',true),
(10,(SELECT id FROM categories WHERE name='INFLUÊNCIA NO TRABALHO'),'Participa na escolha das pessoas com quem trabalha?',true),
(11,(SELECT id FROM categories WHERE name='INFLUÊNCIA NO TRABALHO'),'Pode influenciar a quantidade de trabalho que lhe compete a si?',true),
(12,(SELECT id FROM categories WHERE name='INFLUÊNCIA NO TRABALHO'),'Tem alguma influência sobre o tipo de tarefas que faz?',true),
(13,(SELECT id FROM categories WHERE name='POSSIBILIDADES DE DESENVOLVIMENTO'),'O seu trabalho exige que tenha iniciativa?',true),
(14,(SELECT id FROM categories WHERE name='POSSIBILIDADES DE DESENVOLVIMENTO'),'O seu trabalho permite-lhe aprender coisas novas?',true),
(15,(SELECT id FROM categories WHERE name='POSSIBILIDADES DE DESENVOLVIMENTO'),'O seu trabalho permite-lhe usar as suas habilidades ou perícias?',true),
(16,(SELECT id FROM categories WHERE name='PREVISIBILIDADE'),'No seu local de trabalho, é informado com antecedência sobre decisões importantes, mudanças ou planos para o futuro?',true),
(17,(SELECT id FROM categories WHERE name='PREVISIBILIDADE'),'Recebe toda a informação de que necessita para fazer bem o seu trabalho?',true),
(18,(SELECT id FROM categories WHERE name='TRANSPARÊNCIA DO PAPEL LABORAL'),'O seu trabalho apresenta objectivos claros?',true),
(19,(SELECT id FROM categories WHERE name='TRANSPARÊNCIA DO PAPEL LABORAL'),'Sabe exactamente quais as suas responsabilidades?',true),
(20,(SELECT id FROM categories WHERE name='TRANSPARÊNCIA DO PAPEL LABORAL'),'Sabe exactamente o que é esperado de si?',true),
(21,(SELECT id FROM categories WHERE name='RECOMPENSAS'),'O seu trabalho é reconhecido e apreciado pela gerência?',true),
(22,(SELECT id FROM categories WHERE name='RECOMPENSAS'),'A gerência do seu local de trabalho respeita-o?',true),
(23,(SELECT id FROM categories WHERE name='RECOMPENSAS'),'É tratado de forma justa no seu local de trabalho?',true),
(24,(SELECT id FROM categories WHERE name='CONFLITOS LABORAIS'),'Faz coisas no seu trabalho que uns concordam mas outros não?',false),
(25,(SELECT id FROM categories WHERE name='CONFLITOS LABORAIS'),'Por vezes tem que fazer coisas que deveriam ser feitas de outra maneira?',false),
(26,(SELECT id FROM categories WHERE name='CONFLITOS LABORAIS'),'Por vezes tem que fazer coisas que considera desnecessárias?',false),
(27,(SELECT id FROM categories WHERE name='APOIO SOCIAL DE COLEGAS'),'Com que frequência tem ajuda e apoio dos seus colegas de trabalho?',true),
(28,(SELECT id FROM categories WHERE name='APOIO SOCIAL DE COLEGAS'),'Com que frequência os seus colegas estão dispostos a ouvi-lo(a) sobre os seus problemas de trabalho?',true),
(29,(SELECT id FROM categories WHERE name='APOIO SOCIAL DE COLEGAS'),'Com que frequência os seus colegas falam consigo acerca do seu desempenho laboral?',true),
(30,(SELECT id FROM categories WHERE name='APOIO SOCIAL DE SUPERIORES'),'Com que frequência o seu superior imediato fala consigo sobre como está a decorrer o seu trabalho?',true),
(31,(SELECT id FROM categories WHERE name='APOIO SOCIAL DE SUPERIORES'),'Com que frequência tem ajuda e apoio do seu superior imediato?',true),
(32,(SELECT id FROM categories WHERE name='APOIO SOCIAL DE SUPERIORES'),'Com que frequência é que o seu superior imediato fala consigo em relação ao seu desempenho laboral?',true),
(33,(SELECT id FROM categories WHERE name='COMUNIDADE SOCIAL NO TRABALHO'),'Existe um bom ambiente de trabalho entre si e os seus colegas?',true),
(34,(SELECT id FROM categories WHERE name='COMUNIDADE SOCIAL NO TRABALHO'),'Existe uma boa cooperação entre os colegas de trabalho?',true),
(35,(SELECT id FROM categories WHERE name='COMUNIDADE SOCIAL NO TRABALHO'),'No seu local de trabalho sente-se parte de uma comunidade?',true),
(36,(SELECT id FROM categories WHERE name='QUALIDADE DA LIDERANÇA'),'Oferece aos indivíduos e ao grupo boas oportunidades de desenvolvimento?',true),
(37,(SELECT id FROM categories WHERE name='QUALIDADE DA LIDERANÇA'),'Dá prioridade à satisfação no trabalho?',true),
(38,(SELECT id FROM categories WHERE name='QUALIDADE DA LIDERANÇA'),'É bom no planeamento do trabalho?',true),
(39,(SELECT id FROM categories WHERE name='QUALIDADE DA LIDERANÇA'),'É bom a resolver conflitos?',true),
(40,(SELECT id FROM categories WHERE name='CONFIANÇA HORIZONTAL'),'Os funcionários ocultam informações uns dos outros?',false),
(41,(SELECT id FROM categories WHERE name='CONFIANÇA HORIZONTAL'),'Os funcionários ocultam informação à gerência?',false),
(42,(SELECT id FROM categories WHERE name='CONFIANÇA HORIZONTAL'),'Os funcionários confiam uns nos outros de um modo geral?',true),
(43,(SELECT id FROM categories WHERE name='CONFIANÇA VERTICAL'),'A gerência confia nos seus funcionários para fazerem o seu trabalho bem?',true),
(44,(SELECT id FROM categories WHERE name='CONFIANÇA VERTICAL'),'Confia na informação que lhe é transmitida pela gerência?',true),
(45,(SELECT id FROM categories WHERE name='CONFIANÇA VERTICAL'),'A gerência oculta informação aos seus funcionários?',false),
(46,(SELECT id FROM categories WHERE name='JUSTIÇA E RESPEITO'),'Os conflitos são resolvidos de uma forma justa?',true),
(47,(SELECT id FROM categories WHERE name='JUSTIÇA E RESPEITO'),'As sugestões dos funcionários são tratadas de forma séria pela gerência?',true),
(48,(SELECT id FROM categories WHERE name='JUSTIÇA E RESPEITO'),'O trabalho é igualmente distribuído pelos funcionários?',true),
(49,(SELECT id FROM categories WHERE name='AUTO-EFICÁCIA'),'Sou sempre capaz de resolver problemas, se tentar o suficiente.',true),
(50,(SELECT id FROM categories WHERE name='AUTO-EFICÁCIA'),'É-me fácil seguir os meus planos e atingir os meus objectivos.',true),
(51,(SELECT id FROM categories WHERE name='SIGNIFICADO DO TRABALHO'),'O seu trabalho tem algum significado para si?',true),
(52,(SELECT id FROM categories WHERE name='SIGNIFICADO DO TRABALHO'),'Sente que o seu trabalho é importante?',true),
(53,(SELECT id FROM categories WHERE name='SIGNIFICADO DO TRABALHO'),'Sente-se motivado e envolvido com o seu trabalho?',true),
(54,(SELECT id FROM categories WHERE name='COMPROMISSO COM O LOCAL DE TRABALHO'),'Gosta de falar com os outros sobre o seu local de trabalho?',true),
(55,(SELECT id FROM categories WHERE name='COMPROMISSO COM O LOCAL DE TRABALHO'),'Sente que os problemas do seu local de trabalho são seus também?',true),
(56,(SELECT id FROM categories WHERE name='SATISFAÇÃO NO TRABALHO'),'As suas perspectivas de trabalho?',true),
(57,(SELECT id FROM categories WHERE name='SATISFAÇÃO NO TRABALHO'),'As condições físicas do seu local de trabalho?',true),
(58,(SELECT id FROM categories WHERE name='SATISFAÇÃO NO TRABALHO'),'A forma como as suas capacidades são utilizadas?',true),
(59,(SELECT id FROM categories WHERE name='SATISFAÇÃO NO TRABALHO'),'O seu trabalho de uma forma global?',true),
(60,(SELECT id FROM categories WHERE name='INSEGURANÇA LABORAL'),'Sente-se preocupado em ficar desempregado?',false),
(61,(SELECT id FROM categories WHERE name='SAÚDE GERAL'),'Em geral, sente que a sua saúde é:',true),
(62,(SELECT id FROM categories WHERE name='CONFLITO TRABALHO/FAMÍLIA'),'Sente que o seu trabalho lhe exige muita energia que acaba por afectar a sua vida privada negativamente?',false),
(63,(SELECT id FROM categories WHERE name='CONFLITO TRABALHO/FAMÍLIA'),'Sente que o seu trabalho lhe exige muito tempo que acaba por afectar a sua vida privada negativamente?',false),
(64,(SELECT id FROM categories WHERE name='CONFLITO TRABALHO/FAMÍLIA'),'A sua família e os seus amigos dizem-lhe que trabalha demais?',false),
(65,(SELECT id FROM categories WHERE name='PROBLEMAS EM DORMIR'),'Dificuldade a adormecer?',false),
(66,(SELECT id FROM categories WHERE name='PROBLEMAS EM DORMIR'),'Acordou várias vezes durante a noite e depois não conseguia adormecer novamente?',false),
(67,(SELECT id FROM categories WHERE name='BURNOUT'),'Fisicamente exausto?',false),
(68,(SELECT id FROM categories WHERE name='BURNOUT'),'Emocionalmente exausto?',false),
(69,(SELECT id FROM categories WHERE name='STRESS'),'Irritado?',false),
(70,(SELECT id FROM categories WHERE name='STRESS'),'Ansioso?',false),
(71,(SELECT id FROM categories WHERE name='SINTOMAS DEPRESSIVOS'),'Triste?',false),
(72,(SELECT id FROM categories WHERE name='SINTOMAS DEPRESSIVOS'),'Falta de interesse por coisas quotidianas?',false),
(73,(SELECT id FROM categories WHERE name='COMPORTAMENTOS OFENSIVOS'),'Tem sido alvo de insultos ou provocações verbais?',false),
(74,(SELECT id FROM categories WHERE name='COMPORTAMENTOS OFENSIVOS'),'Tem sido exposto a assédio sexual indesejado?',false),
(75,(SELECT id FROM categories WHERE name='COMPORTAMENTOS OFENSIVOS'),'Tem sido exposto a ameaças de violência?',false),
(76,(SELECT id FROM categories WHERE name='COMPORTAMENTOS OFENSIVOS'),'Tem sido exposto a violência física?',false)
ON CONFLICT (question_number) DO NOTHING;


-- ██████████████████████████████████████████████
-- PARTE 2: SEMÁFORO + CLASSIFICAÇÃO DE RISCO
-- ██████████████████████████████████████████████

CREATE TABLE IF NOT EXISTS risk_classifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  min_score NUMERIC(5,1) NOT NULL,
  max_score NUMERIC(5,1) NOT NULL,
  risk_category TEXT NOT NULL CHECK (risk_category IN ('Green', 'Yellow', 'Red')),
  risk_level TEXT NOT NULL,
  action_required TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Verde
INSERT INTO risk_classifications (category_id, min_score, max_score, risk_category, risk_level, action_required)
SELECT c.id, 0.0, 33.3, 'Green', 'Favorável (Risco Baixo)',
  'Situação favorável. Manter monitoramento regular e boas práticas vigentes.'
FROM categories c;

-- Amarelo
INSERT INTO risk_classifications (category_id, min_score, max_score, risk_category, risk_level, action_required)
SELECT c.id, 33.4, 66.6, 'Yellow', 'Intermediário (Risco Médio)',
  'Situação intermediária. Planejar ações de melhoria e monitorar evolução nos próximos ciclos.'
FROM categories c;

-- Vermelho
INSERT INTO risk_classifications (category_id, min_score, max_score, risk_category, risk_level, action_required)
SELECT c.id, 66.7, 100.0, 'Red', 'Risco (Risco Alto)',
  'AÇÃO IMEDIATA: Intervenção obrigatória. Acionar gestão, RH e saúde ocupacional.'
FROM categories c;

ALTER TABLE risk_classifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Leitura publica risk_classifications" ON risk_classifications FOR SELECT USING (true);


-- ██████████████████████████████████████████████
-- PARTE 3: MATRIZ PGR (Probabilidade x Severidade)
-- ██████████████████████████████████████████████

CREATE TABLE IF NOT EXISTS severity_levels (
  level INTEGER PRIMARY KEY CHECK (level >= 1 AND level <= 5),
  name TEXT NOT NULL, description TEXT NOT NULL
);
INSERT INTO severity_levels VALUES
  (1,'Negligenciável','Sem danos ou agravos'),(2,'Baixa','Danos sem afastamentos'),
  (3,'Moderada','Danos com afastamentos'),(4,'Alta','Danos permanentes ou de difícil reversão'),
  (5,'Crítica','Óbito ou incapacitação total')
ON CONFLICT (level) DO NOTHING;

CREATE TABLE IF NOT EXISTS category_severity (
  category_id UUID PRIMARY KEY REFERENCES categories(id) ON DELETE CASCADE,
  severity_level INTEGER NOT NULL REFERENCES severity_levels(level),
  justification TEXT
);

-- Severidade 5
INSERT INTO category_severity (category_id, severity_level, justification)
SELECT id, 5, 'Impacto crítico' FROM categories WHERE name IN ('SIGNIFICADO DO TRABALHO','SAÚDE GERAL','COMPORTAMENTOS OFENSIVOS');

-- Severidade 4
INSERT INTO category_severity (category_id, severity_level, justification)
SELECT id, 4, 'Risco psicossocial com potencial de danos permanentes' FROM categories WHERE name NOT IN ('SIGNIFICADO DO TRABALHO','SAÚDE GERAL','COMPORTAMENTOS OFENSIVOS');

CREATE TABLE IF NOT EXISTS probability_levels (
  level INTEGER PRIMARY KEY CHECK (level >= 1 AND level <= 5),
  name TEXT NOT NULL, score_min NUMERIC NOT NULL, score_max NUMERIC NOT NULL, description TEXT
);
INSERT INTO probability_levels VALUES
  (1,'Improvável',0,20,'Score 0-20%'),(2,'Pouco provável',20.1,40,'Score 21-40%'),
  (3,'Provável',40.1,60,'Score 41-60%'),(4,'Muito Provável',60.1,80,'Score 61-80%'),
  (5,'Frequente',80.1,100,'Score 81-100%')
ON CONFLICT (level) DO NOTHING;

CREATE TABLE IF NOT EXISTS risk_matrix (
  probability_level INTEGER NOT NULL, severity_level INTEGER NOT NULL REFERENCES severity_levels(level),
  risk_score INTEGER NOT NULL, risk_grade TEXT NOT NULL,
  PRIMARY KEY (probability_level, severity_level)
);
INSERT INTO risk_matrix VALUES
  (1,1,1,'Baixo'),(1,2,4,'Baixo'),(1,3,8,'Tolerável'),(1,4,14,'Moderado'),(1,5,19,'Significativo'),
  (2,1,2,'Baixo'),(2,2,6,'Tolerável'),(2,3,12,'Moderado'),(2,4,17,'Significativo'),(2,5,22,'Intolerável'),
  (3,1,3,'Baixo'),(3,2,7,'Tolerável'),(3,3,13,'Moderado'),(3,4,18,'Significativo'),(3,5,23,'Intolerável'),
  (4,1,5,'Tolerável'),(4,2,10,'Moderado'),(4,3,15,'Significativo'),(4,4,20,'Intolerável'),(4,5,24,'Intolerável'),
  (5,1,9,'Moderado'),(5,2,11,'Moderado'),(5,3,16,'Significativo'),(5,4,21,'Intolerável'),(5,5,25,'Intolerável')
ON CONFLICT DO NOTHING;

ALTER TABLE severity_levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE category_severity ENABLE ROW LEVEL SECURITY;
ALTER TABLE risk_matrix ENABLE ROW LEVEL SECURITY;
ALTER TABLE probability_levels ENABLE ROW LEVEL SECURITY;
CREATE POLICY "read severity_levels" ON severity_levels FOR SELECT USING (true);
CREATE POLICY "read category_severity" ON category_severity FOR SELECT USING (true);
CREATE POLICY "read risk_matrix" ON risk_matrix FOR SELECT USING (true);
CREATE POLICY "read probability_levels" ON probability_levels FOR SELECT USING (true);


-- ██████████████████████████████████████████████
-- PARTE 4: VIEWS
-- ██████████████████████████████████████████████

-- View: Respostas completas com semáforo
CREATE OR REPLACE VIEW vw_respostas_completas AS
SELECT
  e.id AS employee_id, e.name AS employee_name,
  d.id AS department_id, d.name AS department_name,
  s.id AS submission_id, s.submitted_at,
  q.question_number, q.question_text, q.is_inverted,
  c.id AS category_id, c.name AS category_name,
  a.score AS score_original,
  CASE WHEN q.is_inverted=false THEN ROUND(((a.score-1)::NUMERIC/4)*100) ELSE ROUND(((5-a.score)::NUMERIC/4)*100) END AS score_0_100,
  rc.risk_category AS semaforo_cor, rc.risk_level AS semaforo_nivel, rc.action_required AS acao_recomendada
FROM answers a
  JOIN submissions s ON a.submission_id=s.id JOIN employees e ON s.employee_id=e.id
  JOIN departments d ON e.department_id=d.id JOIN questions q ON a.question_id=q.id
  JOIN categories c ON q.category_id=c.id
  LEFT JOIN risk_classifications rc ON rc.category_id=c.id
    AND (CASE WHEN q.is_inverted=false THEN ROUND(((a.score-1)::NUMERIC/4)*100) ELSE ROUND(((5-a.score)::NUMERIC/4)*100) END) >= rc.min_score
    AND (CASE WHEN q.is_inverted=false THEN ROUND(((a.score-1)::NUMERIC/4)*100) ELSE ROUND(((5-a.score)::NUMERIC/4)*100) END) <= rc.max_score;

-- View: Média por categoria/setor com semáforo
CREATE OR REPLACE VIEW vw_media_por_categoria_setor AS
WITH medias AS (
  SELECT d.id AS department_id, d.name AS department_name, c.id AS category_id, c.name AS category_name,
    ROUND(AVG(CASE WHEN q.is_inverted=false THEN ((a.score-1)::NUMERIC/4)*100 ELSE ((5-a.score)::NUMERIC/4)*100 END),1) AS score_medio,
    COUNT(DISTINCT s.id) AS total_submissions, COUNT(DISTINCT s.employee_id) AS total_respondentes
  FROM answers a JOIN submissions s ON a.submission_id=s.id JOIN employees e ON s.employee_id=e.id
    JOIN departments d ON e.department_id=d.id JOIN questions q ON a.question_id=q.id JOIN categories c ON q.category_id=c.id
  GROUP BY d.id, d.name, c.id, c.name
)
SELECT m.*, rc.risk_category AS semaforo_cor, rc.risk_level AS semaforo_nivel, rc.action_required AS acao_recomendada,
  CASE rc.risk_category WHEN 'Green' THEN '#22c55e' WHEN 'Yellow' THEN '#eab308' WHEN 'Red' THEN '#ef4444' END AS cor_hex
FROM medias m LEFT JOIN risk_classifications rc ON rc.category_id=m.category_id AND m.score_medio>=rc.min_score AND m.score_medio<=rc.max_score;

-- View: Planilha PGR completa
CREATE OR REPLACE VIEW vw_pgr_completo AS
WITH scores AS (
  SELECT d.id AS department_id, d.name AS department_name, c.id AS category_id, c.name AS category_name,
    (SELECT COUNT(*) FROM employees e2 WHERE e2.department_id=d.id) AS qtd_funcionarios,
    COUNT(DISTINCT s.employee_id) FILTER (WHERE a.score>=4) AS trabalhadores_expostos,
    COUNT(DISTINCT s.employee_id) AS total_respondentes,
    ROUND(AVG(CASE WHEN q.is_inverted=false THEN ((a.score-1)::NUMERIC/4)*100 ELSE ((5-a.score)::NUMERIC/4)*100 END),1) AS score_medio
  FROM answers a JOIN submissions s ON a.submission_id=s.id JOIN employees e ON s.employee_id=e.id
    JOIN departments d ON e.department_id=d.id JOIN questions q ON a.question_id=q.id JOIN categories c ON q.category_id=c.id
  GROUP BY d.id, d.name, c.id, c.name
)
SELECT sc.qtd_funcionarios, sc.department_name AS grupo_homogeneo, 'Psicossocial' AS natureza_perigo,
  sc.category_name AS descricao_perigo, sc.trabalhadores_expostos,
  CASE WHEN sc.total_respondentes>0 THEN ROUND((sc.trabalhadores_expostos::NUMERIC/sc.total_respondentes)*100)||'%' ELSE '0%' END AS incidencia,
  pl.level AS probabilidade, cs.severity_level AS severidade, rm.risk_score AS grau_risco,
  rm.risk_grade AS classificacao_risco,
  CASE rm.risk_grade WHEN 'Baixo' THEN 'Ações administrativas' WHEN 'Tolerável' THEN 'Monitoramento contínuo'
    WHEN 'Moderado' THEN 'Planejar ações de controle' WHEN 'Significativo' THEN 'Medidas prioritárias'
    WHEN 'Intolerável' THEN 'Medidas urgentes e imediatas' END AS medidas_controle,
  'Pendente' AS status, sc.score_medio, sc.total_respondentes,
  CASE rm.risk_grade WHEN 'Baixo' THEN '#22c55e' WHEN 'Tolerável' THEN '#eab308' WHEN 'Moderado' THEN '#f97316'
    WHEN 'Significativo' THEN '#ef4444' WHEN 'Intolerável' THEN '#991b1b' END AS cor_hex
FROM scores sc
  JOIN category_severity cs ON sc.category_id=cs.category_id
  JOIN probability_levels pl ON sc.score_medio>=pl.score_min AND sc.score_medio<=pl.score_max
  JOIN risk_matrix rm ON pl.level=rm.probability_level AND cs.severity_level=rm.severity_level;

-- View: Resumo por setor
CREATE OR REPLACE VIEW vw_resumo_risco_departamento AS
SELECT grupo_homogeneo, qtd_funcionarios, COUNT(*) AS total_categorias,
  COUNT(*) FILTER (WHERE classificacao_risco='Baixo') AS qtd_baixo,
  COUNT(*) FILTER (WHERE classificacao_risco='Tolerável') AS qtd_toleravel,
  COUNT(*) FILTER (WHERE classificacao_risco='Moderado') AS qtd_moderado,
  COUNT(*) FILTER (WHERE classificacao_risco='Significativo') AS qtd_significativo,
  COUNT(*) FILTER (WHERE classificacao_risco='Intolerável') AS qtd_intoleravel,
  CASE WHEN COUNT(*) FILTER (WHERE classificacao_risco='Intolerável')>0 THEN 'Intolerável'
    WHEN COUNT(*) FILTER (WHERE classificacao_risco='Significativo')>0 THEN 'Significativo'
    WHEN COUNT(*) FILTER (WHERE classificacao_risco='Moderado')>0 THEN 'Moderado'
    WHEN COUNT(*) FILTER (WHERE classificacao_risco='Tolerável')>0 THEN 'Tolerável' ELSE 'Baixo' END AS risco_global
FROM vw_pgr_completo GROUP BY grupo_homogeneo, qtd_funcionarios;


-- ██████████████████████████████████████████████
-- PARTE 5: EMPRESAS E SETORES DEMO
-- ██████████████████████████████████████████████

INSERT INTO empresas (nome, cnpj) VALUES
  ('Hospital São Lucas','12.345.678/0001-01'),
  ('Indústria MetalSul','23.456.789/0001-02'),
  ('Escola Futuro Brilhante','34.567.890/0001-03')
ON CONFLICT (cnpj) DO NOTHING;

-- Hospital
INSERT INTO departments (empresa_id, name) VALUES
  ((SELECT id FROM empresas WHERE cnpj='12.345.678/0001-01'),'Pediatria'),
  ((SELECT id FROM empresas WHERE cnpj='12.345.678/0001-01'),'Emergência'),
  ((SELECT id FROM empresas WHERE cnpj='12.345.678/0001-01'),'Recepção'),
  ((SELECT id FROM empresas WHERE cnpj='12.345.678/0001-01'),'Enfermagem UTI'),
  ((SELECT id FROM empresas WHERE cnpj='12.345.678/0001-01'),'Administrativo');
-- Indústria
INSERT INTO departments (empresa_id, name) VALUES
  ((SELECT id FROM empresas WHERE cnpj='23.456.789/0001-02'),'Produção'),
  ((SELECT id FROM empresas WHERE cnpj='23.456.789/0001-02'),'Logística'),
  ((SELECT id FROM empresas WHERE cnpj='23.456.789/0001-02'),'Qualidade'),
  ((SELECT id FROM empresas WHERE cnpj='23.456.789/0001-02'),'Manutenção'),
  ((SELECT id FROM empresas WHERE cnpj='23.456.789/0001-02'),'RH');
-- Escola
INSERT INTO departments (empresa_id, name) VALUES
  ((SELECT id FROM empresas WHERE cnpj='34.567.890/0001-03'),'Professores Fundamental'),
  ((SELECT id FROM empresas WHERE cnpj='34.567.890/0001-03'),'Professores Médio'),
  ((SELECT id FROM empresas WHERE cnpj='34.567.890/0001-03'),'Coordenação Pedagógica'),
  ((SELECT id FROM empresas WHERE cnpj='34.567.890/0001-03'),'Secretaria'),
  ((SELECT id FROM empresas WHERE cnpj='34.567.890/0001-03'),'Serviços Gerais');


-- ██████████████████████████████████████████████
-- PARTE 6: COLABORADORES (45 total)
-- ██████████████████████████████████████████████

-- Hospital
INSERT INTO employees (name, department_id) VALUES
  ('Ana Silva',(SELECT id FROM departments WHERE name='Pediatria' LIMIT 1)),
  ('Bruno Costa',(SELECT id FROM departments WHERE name='Pediatria' LIMIT 1)),
  ('Carla Mendes',(SELECT id FROM departments WHERE name='Pediatria' LIMIT 1)),
  ('Diego Oliveira',(SELECT id FROM departments WHERE name='Emergência' LIMIT 1)),
  ('Elena Ramos',(SELECT id FROM departments WHERE name='Emergência' LIMIT 1)),
  ('Felipe Santos',(SELECT id FROM departments WHERE name='Emergência' LIMIT 1)),
  ('Gabriela Lima',(SELECT id FROM departments WHERE name='Recepção' LIMIT 1)),
  ('Hugo Ferreira',(SELECT id FROM departments WHERE name='Recepção' LIMIT 1)),
  ('Isabela Rocha',(SELECT id FROM departments WHERE name='Recepção' LIMIT 1)),
  ('João Almeida',(SELECT id FROM departments WHERE name='Enfermagem UTI' LIMIT 1)),
  ('Karen Souza',(SELECT id FROM departments WHERE name='Enfermagem UTI' LIMIT 1)),
  ('Lucas Barbosa',(SELECT id FROM departments WHERE name='Enfermagem UTI' LIMIT 1)),
  ('Marina Dias',(SELECT id FROM departments WHERE name='Administrativo' LIMIT 1)),
  ('Nelson Pires',(SELECT id FROM departments WHERE name='Administrativo' LIMIT 1)),
  ('Olívia Martins',(SELECT id FROM departments WHERE name='Administrativo' LIMIT 1));
-- Indústria
INSERT INTO employees (name, department_id) VALUES
  ('Paulo Ribeiro',(SELECT id FROM departments WHERE name='Produção' LIMIT 1)),
  ('Queila Nunes',(SELECT id FROM departments WHERE name='Produção' LIMIT 1)),
  ('Rafael Teixeira',(SELECT id FROM departments WHERE name='Produção' LIMIT 1)),
  ('Sandra Moreira',(SELECT id FROM departments WHERE name='Logística' LIMIT 1)),
  ('Thiago Cunha',(SELECT id FROM departments WHERE name='Logística' LIMIT 1)),
  ('Úrsula Cardoso',(SELECT id FROM departments WHERE name='Logística' LIMIT 1)),
  ('Vinícius Araujo',(SELECT id FROM departments WHERE name='Qualidade' LIMIT 1)),
  ('Wanda Gomes',(SELECT id FROM departments WHERE name='Qualidade' LIMIT 1)),
  ('Xavier Lopes',(SELECT id FROM departments WHERE name='Qualidade' LIMIT 1)),
  ('Yara Pereira',(SELECT id FROM departments WHERE name='Manutenção' LIMIT 1)),
  ('Zé Carlos',(SELECT id FROM departments WHERE name='Manutenção' LIMIT 1)),
  ('Amanda Freitas',(SELECT id FROM departments WHERE name='Manutenção' LIMIT 1)),
  ('Beatriz Campos',(SELECT id FROM departments WHERE name='RH' LIMIT 1)),
  ('Caio Monteiro',(SELECT id FROM departments WHERE name='RH' LIMIT 1)),
  ('Débora Vieira',(SELECT id FROM departments WHERE name='RH' LIMIT 1));
-- Escola
INSERT INTO employees (name, department_id) VALUES
  ('Eduardo Bastos',(SELECT id FROM departments WHERE name='Professores Fundamental' LIMIT 1)),
  ('Fátima Correia',(SELECT id FROM departments WHERE name='Professores Fundamental' LIMIT 1)),
  ('Gustavo Reis',(SELECT id FROM departments WHERE name='Professores Fundamental' LIMIT 1)),
  ('Helena Duarte',(SELECT id FROM departments WHERE name='Professores Médio' LIMIT 1)),
  ('Igor Machado',(SELECT id FROM departments WHERE name='Professores Médio' LIMIT 1)),
  ('Juliana Castro',(SELECT id FROM departments WHERE name='Professores Médio' LIMIT 1)),
  ('Kleber Fonseca',(SELECT id FROM departments WHERE name='Coordenação Pedagógica' LIMIT 1)),
  ('Letícia Andrade',(SELECT id FROM departments WHERE name='Coordenação Pedagógica' LIMIT 1)),
  ('Marcos Tavares',(SELECT id FROM departments WHERE name='Coordenação Pedagógica' LIMIT 1)),
  ('Natália Borges',(SELECT id FROM departments WHERE name='Secretaria' LIMIT 1)),
  ('Otávio Pinto',(SELECT id FROM departments WHERE name='Secretaria' LIMIT 1)),
  ('Priscila Luz',(SELECT id FROM departments WHERE name='Secretaria' LIMIT 1)),
  ('Renato Melo',(SELECT id FROM departments WHERE name='Serviços Gerais' LIMIT 1)),
  ('Simone Azevedo',(SELECT id FROM departments WHERE name='Serviços Gerais' LIMIT 1)),
  ('Tatiana Coelho',(SELECT id FROM departments WHERE name='Serviços Gerais' LIMIT 1));


-- ██████████████████████████████████████████████
-- PARTE 7: FUNÇÃO PARA INSERIR RESPOSTAS
-- ██████████████████████████████████████████████

CREATE OR REPLACE FUNCTION insert_survey(p_employee_name TEXT, p_scores INTEGER[])
RETURNS VOID AS $$
DECLARE
  v_employee_id UUID; v_submission_id UUID; v_question RECORD; v_idx INTEGER := 1;
BEGIN
  SELECT id INTO v_employee_id FROM employees WHERE name = p_employee_name LIMIT 1;
  IF v_employee_id IS NULL THEN RETURN; END IF;
  INSERT INTO submissions (employee_id) VALUES (v_employee_id) RETURNING id INTO v_submission_id;
  FOR v_question IN SELECT id FROM questions ORDER BY question_number LOOP
    INSERT INTO answers (submission_id, question_id, score) VALUES (v_submission_id, v_question.id, p_scores[v_idx]);
    v_idx := v_idx + 1;
  END LOOP;
END;
$$ LANGUAGE plpgsql;


-- ██████████████████████████████████████████████
-- PARTE 8: RESPOSTAS SIMULADAS (45 colaboradores x 76 perguntas)
-- ██████████████████████████████████████████████

-- HOSPITAL - Emergência (alto risco)
SELECT insert_survey('Diego Oliveira', ARRAY[5,5,5,5,5,4,4,5,2,1,2,2,3,3,3,2,2,4,4,4,2,2,2,4,4,4,2,2,2,2,2,2,3,3,2,2,2,2,2,3,3,3,2,3,4,2,2,2,3,3,4,4,4,3,3,3,3,3,3,4,3,5,5,4,4,4,5,5,4,4,4,4,2,1,1,1]);
SELECT insert_survey('Elena Ramos', ARRAY[4,5,4,5,4,4,5,5,2,2,1,2,3,2,3,2,3,3,4,3,2,3,2,4,5,4,3,2,2,2,2,3,3,2,2,2,3,2,3,4,3,3,3,3,4,3,2,3,3,3,4,4,3,3,3,3,3,3,3,4,3,4,4,5,5,4,4,5,4,5,4,3,2,1,1,1]);
SELECT insert_survey('Felipe Santos', ARRAY[5,4,5,4,5,3,4,4,1,2,2,1,2,3,2,2,2,3,3,3,3,2,2,3,4,3,2,3,2,1,2,2,2,3,2,3,2,2,2,4,4,2,2,2,3,3,3,2,3,3,3,3,3,2,2,2,3,2,3,5,2,4,5,4,4,3,5,4,5,4,4,4,3,2,2,1]);

-- HOSPITAL - UTI (alto risco)
SELECT insert_survey('João Almeida', ARRAY[5,4,5,5,5,3,4,5,2,1,1,2,3,3,2,2,2,3,4,4,2,2,3,4,4,5,2,2,3,2,1,2,3,3,2,2,2,3,2,3,4,3,2,3,4,3,2,2,3,3,4,3,4,3,3,3,3,2,3,4,3,5,4,4,4,5,5,5,5,4,4,4,3,2,1,1]);
SELECT insert_survey('Karen Souza', ARRAY[4,5,4,4,4,4,3,5,2,2,2,1,2,3,3,3,2,4,3,4,3,2,2,3,4,4,3,2,2,2,2,2,3,2,3,3,2,2,3,3,3,2,2,2,4,2,3,2,4,3,3,4,4,3,2,3,2,3,3,3,3,4,5,4,4,4,4,4,4,5,3,4,2,1,1,1]);
SELECT insert_survey('Lucas Barbosa', ARRAY[5,5,5,5,5,4,5,4,1,1,2,1,3,2,3,2,2,3,3,3,2,2,2,4,5,4,2,2,2,1,1,2,2,2,2,2,2,2,2,4,4,3,2,3,4,2,2,2,3,3,3,4,3,3,3,2,2,2,2,5,2,5,5,5,5,4,5,5,5,5,5,4,4,3,2,1]);

-- HOSPITAL - Pediatria (risco médio)
SELECT insert_survey('Ana Silva', ARRAY[3,3,2,3,4,3,3,4,3,2,3,3,4,4,3,3,3,4,4,4,3,3,3,3,3,2,3,3,3,3,3,3,4,3,3,3,3,3,3,2,2,3,3,3,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,3,3,3,3,2,2,1,1,1,1]);
SELECT insert_survey('Bruno Costa', ARRAY[3,4,3,3,3,3,4,3,3,3,2,3,3,4,4,3,4,4,4,3,3,4,3,2,3,3,3,4,3,3,3,4,4,4,3,4,3,4,3,2,3,3,3,4,2,3,3,4,4,3,4,3,4,4,3,4,3,3,4,2,4,3,2,3,2,3,3,2,2,3,2,2,1,1,1,1]);
SELECT insert_survey('Carla Mendes', ARRAY[2,3,3,4,4,3,3,4,3,2,3,2,4,3,4,3,3,3,4,4,4,3,3,3,3,3,4,3,3,3,4,3,3,4,4,3,4,3,3,3,2,3,4,3,2,4,3,3,3,4,3,4,3,3,4,3,4,4,3,3,3,3,3,2,3,3,3,3,3,2,3,2,1,1,1,1]);

-- HOSPITAL - Recepção (risco baixo-médio)
SELECT insert_survey('Gabriela Lima', ARRAY[2,2,1,2,3,2,2,2,3,3,3,3,4,4,4,4,4,4,5,5,4,4,4,2,2,2,4,4,3,4,4,3,4,4,4,4,4,4,4,2,2,4,4,4,2,4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,4,2,2,1,2,1,2,2,2,2,1,1,1,1,1,1]);
SELECT insert_survey('Hugo Ferreira', ARRAY[2,3,2,2,3,2,2,3,3,3,4,3,3,4,3,3,4,4,4,4,4,4,3,2,3,2,4,3,4,3,4,3,4,3,4,4,3,4,3,2,2,4,4,3,2,4,3,4,3,4,4,3,4,4,3,4,4,3,4,2,4,2,2,2,2,2,2,1,2,2,2,1,1,1,1,1]);
SELECT insert_survey('Isabela Rocha', ARRAY[1,2,2,3,2,2,3,2,4,3,3,4,4,4,4,4,3,5,4,4,4,4,4,2,2,3,4,4,3,4,3,4,4,4,4,4,4,3,4,2,2,4,4,4,2,4,4,3,4,4,4,4,4,4,4,4,4,4,4,1,4,1,2,2,1,2,1,2,1,2,1,2,1,1,1,1]);

-- HOSPITAL - Administrativo (risco baixo)
SELECT insert_survey('Marina Dias', ARRAY[1,1,1,2,2,2,2,1,4,4,4,4,4,5,5,4,5,5,5,5,5,5,5,1,1,1,5,5,4,5,5,4,5,5,5,5,5,5,5,1,1,5,5,5,1,5,5,5,5,5,5,5,5,5,5,5,5,5,5,1,5,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]);
SELECT insert_survey('Nelson Pires', ARRAY[2,1,1,2,3,2,2,2,4,4,3,4,4,4,5,4,4,4,5,4,4,5,4,2,1,2,4,4,4,4,4,4,4,4,4,4,4,5,4,2,1,4,4,5,1,4,4,4,4,4,5,4,4,4,5,4,4,4,4,1,4,1,2,1,1,1,1,1,1,1,1,1,1,1,1,1]);
SELECT insert_survey('Olívia Martins', ARRAY[1,2,1,1,2,2,1,1,5,4,4,5,5,5,4,5,4,5,5,5,5,4,5,1,2,1,5,4,5,4,5,5,5,5,4,5,4,5,5,1,1,5,5,5,1,5,5,4,5,5,5,5,5,5,5,5,5,5,5,1,5,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]);

-- INDÚSTRIA - Produção (alto risco)
SELECT insert_survey('Paulo Ribeiro', ARRAY[5,5,5,5,4,3,3,3,1,1,1,1,2,2,2,2,2,3,3,3,2,2,2,4,4,4,2,2,2,2,1,1,2,2,2,2,2,2,2,4,4,2,2,2,4,2,2,2,3,2,2,2,2,2,2,2,2,2,2,5,2,4,4,5,4,4,5,4,4,4,3,3,3,2,2,1]);
SELECT insert_survey('Queila Nunes', ARRAY[4,4,5,5,5,3,4,4,2,1,2,1,2,3,2,2,3,3,3,2,2,3,2,4,5,4,2,3,2,1,2,2,3,2,2,2,3,2,2,4,3,2,3,2,4,2,2,3,3,3,3,2,3,2,3,3,2,3,2,4,2,5,4,4,3,4,4,4,4,3,3,3,2,2,1,1]);
SELECT insert_survey('Rafael Teixeira', ARRAY[5,4,4,4,4,2,3,3,1,1,1,2,3,2,3,2,2,2,3,3,2,2,3,5,4,5,2,2,3,2,1,2,2,3,3,3,2,2,3,3,4,2,2,3,4,3,2,2,2,3,3,3,2,3,2,3,3,2,3,4,3,4,5,4,4,3,4,5,4,4,4,3,3,2,2,2]);

-- INDÚSTRIA - Logística (risco alto)
SELECT insert_survey('Sandra Moreira', ARRAY[4,4,4,4,3,3,3,3,2,2,2,2,3,3,3,3,3,3,3,3,3,3,2,3,4,3,3,3,2,2,3,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,4,3,4,3,4,3,3,4,4,3,4,3,3,2,1,1,1]);
SELECT insert_survey('Thiago Cunha', ARRAY[5,4,5,5,4,3,4,4,2,1,2,1,3,2,2,2,2,3,3,3,2,2,2,4,4,4,2,2,2,2,2,2,3,2,2,2,2,2,2,4,4,2,2,2,4,2,2,2,3,2,2,2,2,2,2,2,2,2,2,5,2,5,5,4,4,4,5,4,4,4,4,3,2,1,1,1]);
SELECT insert_survey('Úrsula Cardoso', ARRAY[4,5,4,4,4,3,3,3,2,2,1,2,3,3,2,2,3,3,4,3,3,2,3,4,3,4,3,2,3,2,3,2,3,3,2,3,2,3,2,3,3,3,3,3,3,3,2,3,3,3,3,3,3,3,2,3,3,3,3,4,3,4,4,3,3,3,4,3,4,3,3,3,2,1,1,1]);

-- INDÚSTRIA - Qualidade (risco baixo-médio)
SELECT insert_survey('Vinícius Araujo', ARRAY[2,2,2,3,3,3,3,2,3,3,3,3,4,4,4,4,4,4,4,4,4,4,4,2,2,2,4,4,3,4,3,4,4,4,4,4,4,4,4,2,2,4,4,4,2,4,4,3,4,4,4,4,4,4,4,4,4,4,4,2,4,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1]);
SELECT insert_survey('Wanda Gomes', ARRAY[2,3,2,2,3,3,2,2,4,3,3,4,4,3,4,3,4,4,4,4,3,4,4,2,3,2,3,4,3,4,3,4,4,4,3,3,4,4,3,2,2,4,4,4,2,3,4,4,4,3,4,4,3,3,4,4,3,4,4,2,4,2,2,2,2,2,2,2,2,2,1,2,1,1,1,1]);
SELECT insert_survey('Xavier Lopes', ARRAY[3,2,2,3,4,3,3,3,3,3,3,3,4,4,3,3,3,4,4,4,4,3,4,3,2,3,3,4,3,3,4,3,4,3,4,4,3,3,4,2,3,3,3,4,2,4,3,4,3,4,3,3,4,4,3,4,3,4,3,3,3,2,3,2,2,2,3,2,2,3,2,2,1,1,1,1]);

-- INDÚSTRIA - Manutenção (risco médio)
SELECT insert_survey('Yara Pereira', ARRAY[3,3,4,4,3,2,3,3,2,2,3,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,2,2,1,1,1]);
SELECT insert_survey('Zé Carlos', ARRAY[4,3,4,4,3,3,3,3,2,2,2,2,3,3,2,2,3,3,3,3,2,3,3,3,4,3,3,2,3,2,3,2,3,3,2,3,2,3,3,3,3,3,3,3,3,3,3,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,4,3,3,3,3,4,3,3,3,2,2,2,1,1]);
SELECT insert_survey('Amanda Freitas', ARRAY[3,4,3,3,3,3,4,3,3,2,2,3,4,3,3,3,3,3,4,3,3,3,3,3,3,3,3,3,3,3,2,3,4,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,4,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,2,1,1,1,1]);

-- INDÚSTRIA - RH (risco baixo)
SELECT insert_survey('Beatriz Campos', ARRAY[1,2,1,2,2,3,2,2,4,4,4,4,5,5,4,4,5,5,5,5,5,4,5,1,2,1,5,5,4,5,4,5,5,5,5,5,5,4,5,1,1,5,5,5,1,5,5,4,5,4,5,5,5,5,5,5,5,5,5,1,5,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]);
SELECT insert_survey('Caio Monteiro', ARRAY[2,1,2,2,3,2,2,1,4,4,4,3,4,5,4,4,4,4,5,5,4,5,4,2,1,2,4,4,5,4,5,4,5,4,4,4,5,4,4,2,1,4,4,4,2,4,4,4,4,4,4,5,4,4,4,4,4,5,4,1,4,1,1,2,1,1,1,2,1,2,1,1,1,1,1,1]);
SELECT insert_survey('Débora Vieira', ARRAY[1,1,1,1,2,2,2,1,5,5,4,5,5,4,5,5,5,5,4,5,5,5,5,1,1,1,5,5,5,5,5,5,5,5,5,5,5,5,5,1,1,5,5,5,1,5,5,5,5,5,5,5,5,5,5,5,5,5,5,1,5,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]);

-- ESCOLA - Professores Fundamental (risco médio-alto)
SELECT insert_survey('Eduardo Bastos', ARRAY[3,3,3,3,4,4,3,5,3,2,2,3,4,4,3,3,3,4,4,3,3,3,3,3,3,3,3,3,3,3,3,3,4,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,4,3,4,4,4,3,4,4,3,3,3,3,3,3,3,4,3,3,3,4,3,3,3,3,2,1,1,1]);
SELECT insert_survey('Fátima Correia', ARRAY[4,3,4,4,4,3,4,5,2,2,2,2,3,3,3,3,3,3,3,4,3,2,3,3,3,4,3,3,3,3,2,3,3,3,3,3,3,2,3,3,3,3,3,3,3,3,3,2,3,3,3,3,3,3,3,3,3,3,3,4,3,4,3,4,4,3,4,4,4,3,3,3,2,1,1,1]);
SELECT insert_survey('Gustavo Reis', ARRAY[3,4,3,3,4,4,3,4,3,2,3,2,4,4,4,3,3,4,3,4,3,3,3,3,3,3,3,4,3,3,3,3,4,4,3,3,4,3,4,3,2,3,3,4,3,3,3,3,3,4,3,4,3,4,3,3,4,3,4,3,4,3,3,3,3,3,3,3,3,3,2,3,1,1,1,1]);

-- ESCOLA - Professores Médio (risco médio-alto)
SELECT insert_survey('Helena Duarte', ARRAY[3,4,3,4,4,4,4,5,3,2,2,3,3,4,4,3,3,3,4,4,3,3,3,3,3,4,3,3,3,2,3,3,3,4,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,4,3,4,3,3,4,3,3,4,3,3,3,4,3,3,3,3,3,3,4,3,2,1,1,1,1]);
SELECT insert_survey('Igor Machado', ARRAY[4,3,4,4,3,4,4,4,2,2,3,2,4,3,3,3,3,3,3,3,2,3,3,4,3,3,3,3,2,2,3,2,3,3,3,3,2,3,3,3,3,3,3,3,3,3,2,3,3,3,3,3,3,3,3,3,3,3,3,4,3,4,3,4,4,3,4,3,3,4,3,3,2,2,1,1]);
SELECT insert_survey('Juliana Castro', ARRAY[3,3,3,3,4,3,3,5,3,3,2,3,4,4,4,3,4,4,4,3,3,4,3,3,3,3,4,3,3,3,3,3,4,3,4,4,3,3,4,2,3,4,3,4,2,4,3,4,4,3,4,4,3,4,4,4,3,4,3,2,4,3,3,3,2,3,3,3,2,3,2,2,1,1,1,1]);

-- ESCOLA - Coordenação (risco médio)
SELECT insert_survey('Kleber Fonseca', ARRAY[3,3,2,3,3,4,3,3,3,3,3,3,4,4,4,3,4,4,4,4,4,4,3,2,3,2,4,3,4,4,3,4,4,4,4,4,4,4,4,2,2,4,4,4,2,4,4,4,4,4,4,4,4,4,4,4,3,4,4,2,4,2,2,2,2,2,2,2,2,2,1,2,1,1,1,1]);
SELECT insert_survey('Letícia Andrade', ARRAY[2,3,2,3,3,3,3,3,4,3,3,3,4,4,4,4,3,4,4,4,4,3,4,2,2,3,4,4,3,3,4,3,4,4,3,4,3,4,3,2,2,4,4,3,2,4,3,3,3,4,4,4,3,3,4,4,4,3,4,2,4,2,3,2,2,2,2,2,2,3,2,1,1,1,1,1]);
SELECT insert_survey('Marcos Tavares', ARRAY[2,2,3,3,4,3,4,3,3,3,3,4,4,3,4,3,4,4,4,4,3,4,4,3,2,2,3,4,3,4,3,3,4,4,4,3,4,3,4,2,2,4,3,4,2,3,4,4,4,3,4,3,4,4,3,4,4,4,3,2,4,2,2,3,2,2,2,3,2,2,1,2,1,1,1,1]);

-- ESCOLA - Secretaria (risco baixo)
SELECT insert_survey('Natália Borges', ARRAY[1,2,1,2,2,2,2,1,4,4,4,4,4,5,4,4,4,5,5,5,5,4,5,1,1,1,5,4,4,4,5,4,5,5,4,4,5,5,4,1,1,5,5,4,1,5,4,4,5,4,5,4,5,5,4,5,4,5,4,1,5,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]);
SELECT insert_survey('Otávio Pinto', ARRAY[2,1,2,2,3,2,2,2,4,3,4,3,4,4,4,4,4,4,4,4,4,4,4,2,2,1,4,4,4,4,4,3,4,4,4,4,4,4,4,2,1,4,4,4,1,4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,4,2,1,2,1,2,1,2,1,2,1,1,1,1,1,1]);
SELECT insert_survey('Priscila Luz', ARRAY[1,1,1,2,2,2,1,1,5,4,5,4,5,5,5,5,5,5,5,5,5,5,5,1,1,1,5,5,5,5,5,5,5,5,5,5,5,5,5,1,1,5,5,5,1,5,5,5,5,5,5,5,5,5,5,5,5,5,5,1,5,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]);

-- ESCOLA - Serviços Gerais (risco médio, insegurança alta)
SELECT insert_survey('Renato Melo', ARRAY[3,3,3,3,2,2,2,2,2,1,2,2,2,2,2,2,2,3,3,3,2,3,2,3,3,3,3,2,2,2,2,2,3,3,2,2,2,2,2,3,3,2,2,2,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,5,2,3,3,3,3,3,3,3,2,3,3,3,2,1,1,1]);
SELECT insert_survey('Simone Azevedo', ARRAY[3,4,3,3,3,2,2,3,2,2,1,2,3,2,2,3,2,3,3,3,3,2,2,3,3,4,2,3,2,2,2,3,3,2,2,2,3,2,3,3,4,2,3,2,4,2,3,2,3,2,2,3,2,2,2,2,3,2,3,5,2,3,4,3,3,3,3,3,3,3,3,2,2,2,1,1]);
SELECT insert_survey('Tatiana Coelho', ARRAY[2,3,3,3,2,2,3,2,2,2,2,1,3,3,2,2,3,3,3,3,3,2,3,3,3,3,3,2,3,2,3,2,3,3,3,3,2,3,2,3,3,3,3,2,3,3,3,2,3,3,3,2,3,3,2,3,2,3,2,4,3,3,3,3,3,2,3,3,3,2,2,3,1,1,1,1]);

-- Limpar função auxiliar
DROP FUNCTION IF EXISTS insert_survey;
