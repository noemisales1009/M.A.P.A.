-- =============================================
-- M.A.P.A. — Matriz de Risco PGR (Probabilidade x Severidade)
-- Baseado na planilha real do PGR
-- Execute no SQL Editor do Supabase APÓS o supabase-copsoq.sql
-- =============================================

-- ============================================
-- 1. TABELA: severity_levels (Níveis de Severidade)
-- ============================================
CREATE TABLE IF NOT EXISTS severity_levels (
  level INTEGER PRIMARY KEY CHECK (level >= 1 AND level <= 5),
  name TEXT NOT NULL,
  description TEXT NOT NULL
);

INSERT INTO severity_levels (level, name, description) VALUES
  (1, 'Negligenciável', 'Sem danos ou agravos'),
  (2, 'Baixa',          'Danos sem afastamentos'),
  (3, 'Moderada',       'Danos com afastamentos'),
  (4, 'Alta',           'Danos permanentes ou de difícil reversão'),
  (5, 'Crítica',        'Óbito ou incapacitação total')
ON CONFLICT (level) DO NOTHING;

-- ============================================
-- 2. TABELA: category_severity
-- Severidade fixa por categoria conforme planilha PGR
-- A maioria é 4 (Alta), algumas são 5 (Crítica)
-- ============================================
CREATE TABLE IF NOT EXISTS category_severity (
  category_id UUID PRIMARY KEY REFERENCES categories(id) ON DELETE CASCADE,
  severity_level INTEGER NOT NULL REFERENCES severity_levels(level),
  justification TEXT
);

-- Severidade 5 (Crítica): Significado do Trabalho, Saúde Geral e Comportamentos Ofensivos
INSERT INTO category_severity (category_id, severity_level, justification)
SELECT id, 5, 'Impacto crítico na saúde e bem-estar global do trabalhador'
FROM categories WHERE name IN ('SIGNIFICADO DO TRABALHO', 'SAÚDE GERAL', 'COMPORTAMENTOS OFENSIVOS');

-- Severidade 4 (Alta): Todas as demais categorias
INSERT INTO category_severity (category_id, severity_level, justification)
SELECT id, 4, 'Risco psicossocial com potencial de danos permanentes'
FROM categories WHERE name IN (
  'EXIGÊNCIAS QUANTITATIVAS',
  'RITMO DE TRABALHO',
  'EXIGÊNCIAS COGNITIVAS',
  'EXIGÊNCIAS EMOCIONAIS',
  'INFLUÊNCIA NO TRABALHO',
  'POSSIBILIDADES DE DESENVOLVIMENTO',
  'PREVISIBILIDADE',
  'TRANSPARÊNCIA DO PAPEL LABORAL',
  'RECOMPENSAS',
  'CONFLITOS LABORAIS',
  'APOIO SOCIAL DE COLEGAS',
  'APOIO SOCIAL DE SUPERIORES',
  'COMUNIDADE SOCIAL NO TRABALHO',
  'QUALIDADE DA LIDERANÇA',
  'CONFIANÇA HORIZONTAL',
  'CONFIANÇA VERTICAL',
  'JUSTIÇA E RESPEITO',
  'AUTO-EFICÁCIA',
  'COMPROMISSO COM O LOCAL DE TRABALHO',
  'SATISFAÇÃO NO TRABALHO',
  'INSEGURANÇA LABORAL',
  'CONFLITO TRABALHO/FAMÍLIA',
  'PROBLEMAS EM DORMIR',
  'BURNOUT',
  'STRESS',
  'SINTOMAS DEPRESSIVOS'
);

-- ============================================
-- 3. TABELA: probability_levels
-- Probabilidade calculada pelo score médio 0-100
-- Convertido para escala 1-5
-- Score 0-20 = 1, 21-40 = 2, 41-60 = 3, 61-80 = 4, 81-100 = 5
-- ============================================
CREATE TABLE IF NOT EXISTS probability_levels (
  level INTEGER PRIMARY KEY CHECK (level >= 1 AND level <= 5),
  name TEXT NOT NULL,
  score_min NUMERIC NOT NULL,
  score_max NUMERIC NOT NULL,
  description TEXT
);

INSERT INTO probability_levels (level, name, score_min, score_max, description) VALUES
  (1, 'Improvável',      0,  20, 'Score médio 0-20%: evento muito raro'),
  (2, 'Pouco provável', 20.1, 40, 'Score médio 21-40%: evento pouco frequente'),
  (3, 'Provável',       40.1, 60, 'Score médio 41-60%: evento possível'),
  (4, 'Muito Provável', 60.1, 80, 'Score médio 61-80%: evento frequente'),
  (5, 'Frequente',      80.1, 100, 'Score médio 81-100%: evento muito frequente')
ON CONFLICT (level) DO NOTHING;

-- ============================================
-- 4. TABELA: risk_matrix (Matriz 5x5)
-- Idêntica à planilha PGR
-- Grau de Risco = Probabilidade x Severidade
-- ============================================
CREATE TABLE IF NOT EXISTS risk_matrix (
  probability_level INTEGER NOT NULL CHECK (probability_level >= 1 AND probability_level <= 5),
  severity_level INTEGER NOT NULL REFERENCES severity_levels(level),
  risk_score INTEGER NOT NULL,
  risk_grade TEXT NOT NULL CHECK (risk_grade IN ('Baixo', 'Tolerável', 'Moderado', 'Significativo', 'Intolerável')),
  PRIMARY KEY (probability_level, severity_level)
);

INSERT INTO risk_matrix (probability_level, severity_level, risk_score, risk_grade) VALUES
  -- Improvável (1)
  (1, 1,  1, 'Baixo'),        (1, 2,  4, 'Baixo'),
  (1, 3,  8, 'Tolerável'),    (1, 4, 14, 'Moderado'),
  (1, 5, 19, 'Significativo'),

  -- Pouco provável (2)
  (2, 1,  2, 'Baixo'),        (2, 2,  6, 'Tolerável'),
  (2, 3, 12, 'Moderado'),     (2, 4, 17, 'Significativo'),
  (2, 5, 22, 'Intolerável'),

  -- Provável (3)
  (3, 1,  3, 'Baixo'),        (3, 2,  7, 'Tolerável'),
  (3, 3, 13, 'Moderado'),     (3, 4, 18, 'Significativo'),
  (3, 5, 23, 'Intolerável'),

  -- Muito Provável (4)
  (4, 1,  5, 'Tolerável'),    (4, 2, 10, 'Moderado'),
  (4, 3, 15, 'Significativo'),(4, 4, 20, 'Intolerável'),
  (4, 5, 24, 'Intolerável'),

  -- Frequente (5)
  (5, 1,  9, 'Moderado'),     (5, 2, 11, 'Moderado'),
  (5, 3, 16, 'Significativo'),(5, 4, 21, 'Intolerável'),
  (5, 5, 25, 'Intolerável')
ON CONFLICT (probability_level, severity_level) DO NOTHING;

-- ============================================
-- 5. VIEW: vw_pgr_completo
-- Gera a planilha PGR completa, igual ao Excel
-- Colunas: Qtd funcionários, Setor, Natureza, Categoria,
--          Fonte, Trabalhadores expostos, Incidência,
--          Probabilidade, Severidade, Grau, Classificação
-- ============================================
CREATE OR REPLACE VIEW vw_pgr_completo AS
WITH scores AS (
  SELECT
    d.id   AS department_id,
    d.name AS department_name,
    c.id   AS category_id,
    c.name AS category_name,

    -- Total de funcionários no setor
    (SELECT COUNT(*) FROM employees e2 WHERE e2.department_id = d.id) AS qtd_funcionarios,

    -- Trabalhadores que relataram exposição (score >= 4)
    COUNT(DISTINCT s.employee_id) FILTER (
      WHERE a.score >= 4
    ) AS trabalhadores_expostos,

    -- Total que responderam
    COUNT(DISTINCT s.employee_id) AS total_respondentes,

    -- Score medio 0-100
    ROUND(AVG(
      CASE
        WHEN q.is_inverted = false THEN ((a.score - 1)::NUMERIC / 4) * 100
        WHEN q.is_inverted = true  THEN ((5 - a.score)::NUMERIC / 4) * 100
      END
    ), 1) AS score_medio

  FROM answers a
    JOIN submissions s ON a.submission_id = s.id
    JOIN employees e   ON s.employee_id = e.id
    JOIN departments d ON e.department_id = d.id
    JOIN questions q   ON a.question_id = q.id
    JOIN categories c  ON q.category_id = c.id
  GROUP BY d.id, d.name, c.id, c.name
)
SELECT
  -- Coluna A: Quantidade de funcionários avaliados
  sc.qtd_funcionarios,

  -- Coluna B: Grupo homogêneo / Setor
  sc.department_name AS grupo_homogeneo,

  -- Coluna C: Natureza do Perigo
  'Psicossocial' AS natureza_perigo,

  -- Coluna D: Descrição do perigo (categoria)
  sc.category_name AS descricao_perigo,

  -- Coluna E: Fonte geradora (categoria resumida)
  sc.category_name AS fonte_geradora,

  -- Coluna F: Trabalhadores que relataram exposição
  sc.trabalhadores_expostos,

  -- Coluna G: Incidência (% expostos)
  CASE
    WHEN sc.total_respondentes > 0
    THEN ROUND((sc.trabalhadores_expostos::NUMERIC / sc.total_respondentes) * 100) || '%'
    ELSE '0%'
  END AS incidencia,

  -- Coluna H: Consequências / Danos / Agravos
  CASE
    WHEN sc.category_name IN ('BURNOUT', 'STRESS', 'SINTOMAS DEPRESSIVOS')
      THEN 'Transtornos mentais, afastamento'
    WHEN sc.category_name IN ('PROBLEMAS EM DORMIR')
      THEN 'Distúrbios do sono, fadiga crônica'
    WHEN sc.category_name IN ('COMPORTAMENTOS OFENSIVOS')
      THEN 'Assédio, violência, danos psicológicos graves'
    WHEN sc.category_name IN ('SAÚDE GERAL')
      THEN 'Deterioração da saúde física e mental'
    WHEN sc.category_name IN ('CONFLITO TRABALHO/FAMÍLIA')
      THEN 'Conflitos familiares, sobrecarga'
    WHEN sc.category_name IN ('INSEGURANÇA LABORAL')
      THEN 'Ansiedade, instabilidade emocional'
    ELSE 'Desgaste psicossocial, queda de produtividade'
  END AS consequencias,

  -- Coluna I: Probabilidade (1-5)
  pl.level AS probabilidade,

  -- Coluna J: Severidade (4 ou 5 conforme planilha)
  cs.severity_level AS severidade,

  -- Coluna K: Grau de Risco (número da matriz)
  rm.risk_score AS grau_risco,

  -- Coluna L: Classificação de Risco
  rm.risk_grade AS classificacao_risco,

  -- Coluna M: Medidas de controle recomendadas
  CASE rm.risk_grade
    WHEN 'Baixo'         THEN 'Manter ações administrativas e registro. Monitorar indicadores.'
    WHEN 'Tolerável'     THEN 'Monitoramento contínuo dos indicadores. Ações preventivas de rotina.'
    WHEN 'Moderado'      THEN 'Planejar ações para controle. Ex: treinamento de líderes em saúde mental.'
    WHEN 'Significativo' THEN 'Requer medidas prioritárias. Ex: reestruturação de processos, apoio psicológico.'
    WHEN 'Intolerável'   THEN 'Requer medidas urgentes e imediatas. Intervenção obrigatória.'
  END AS medidas_controle,

  -- Coluna N: Status
  'Pendente' AS status,

  -- Dados extras para o dashboard
  sc.score_medio,
  sc.total_respondentes,

  -- Cor para o frontend
  CASE rm.risk_grade
    WHEN 'Baixo'         THEN '#22c55e'
    WHEN 'Tolerável'     THEN '#eab308'
    WHEN 'Moderado'      THEN '#f97316'
    WHEN 'Significativo' THEN '#ef4444'
    WHEN 'Intolerável'   THEN '#991b1b'
  END AS cor_hex

FROM scores sc
  JOIN category_severity cs ON sc.category_id = cs.category_id
  JOIN probability_levels pl
    ON sc.score_medio >= pl.score_min
   AND sc.score_medio <= pl.score_max
  JOIN risk_matrix rm
    ON pl.level = rm.probability_level
   AND cs.severity_level = rm.severity_level;

-- ============================================
-- 6. VIEW: vw_resumo_risco_departamento
-- Resumo geral por setor (para dashboard)
-- ============================================
CREATE OR REPLACE VIEW vw_resumo_risco_departamento AS
SELECT
  department_name AS grupo_homogeneo,
  qtd_funcionarios,
  COUNT(*) AS total_categorias_avaliadas,
  COUNT(*) FILTER (WHERE classificacao_risco = 'Baixo')         AS qtd_baixo,
  COUNT(*) FILTER (WHERE classificacao_risco = 'Tolerável')     AS qtd_toleravel,
  COUNT(*) FILTER (WHERE classificacao_risco = 'Moderado')      AS qtd_moderado,
  COUNT(*) FILTER (WHERE classificacao_risco = 'Significativo') AS qtd_significativo,
  COUNT(*) FILTER (WHERE classificacao_risco = 'Intolerável')   AS qtd_intoleravel,
  MAX(grau_risco) AS pior_grau,
  -- Risco global do setor (pior classificação encontrada)
  CASE
    WHEN COUNT(*) FILTER (WHERE classificacao_risco = 'Intolerável')   > 0 THEN 'Intolerável'
    WHEN COUNT(*) FILTER (WHERE classificacao_risco = 'Significativo') > 0 THEN 'Significativo'
    WHEN COUNT(*) FILTER (WHERE classificacao_risco = 'Moderado')      > 0 THEN 'Moderado'
    WHEN COUNT(*) FILTER (WHERE classificacao_risco = 'Tolerável')     > 0 THEN 'Tolerável'
    ELSE 'Baixo'
  END AS risco_global
FROM vw_pgr_completo
GROUP BY department_name, qtd_funcionarios;

-- ============================================
-- 7. RLS para novas tabelas
-- ============================================
ALTER TABLE severity_levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE category_severity ENABLE ROW LEVEL SECURITY;
ALTER TABLE risk_matrix ENABLE ROW LEVEL SECURITY;
ALTER TABLE probability_levels ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Leitura publica severity_levels" ON severity_levels FOR SELECT USING (true);
CREATE POLICY "Leitura publica category_severity" ON category_severity FOR SELECT USING (true);
CREATE POLICY "Leitura publica risk_matrix" ON risk_matrix FOR SELECT USING (true);
CREATE POLICY "Leitura publica probability_levels" ON probability_levels FOR SELECT USING (true);
