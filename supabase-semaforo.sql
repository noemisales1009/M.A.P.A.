-- =============================================
-- M.A.P.A. — Semáforo COPSOQ + Classificação de Risco
-- Execute no SQL Editor do Supabase APÓS supabase-copsoq.sql
-- =============================================

-- ============================================
-- 1. TABELA: risk_classifications
-- Faixas de risco por categoria (considera inversão)
-- ============================================
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

-- ============================================
-- 2. FUNÇÃO: Popula risk_classifications
-- para TODAS as categorias automaticamente
--
-- LÓGICA DO SEMÁFORO COPSOQ:
--
-- Categorias NORMAIS (risco = score alto):
--   0-33   = Verde (Favorável)
--   34-66  = Amarelo (Intermediário)
--   67-100 = Vermelho (Risco)
--
-- Categorias INVERTIDAS (protetor = score alto):
--   Já invertemos o score na conversão 0-100,
--   então a mesma faixa se aplica:
--   Score convertido 0-33 = Verde (o fator protetor está presente)
--   Score convertido 34-66 = Amarelo
--   Score convertido 67-100 = Vermelho (o fator protetor está ausente)
-- ============================================

-- Verde (Favorável) para todas as categorias
INSERT INTO risk_classifications (category_id, min_score, max_score, risk_category, risk_level, action_required)
SELECT
  c.id,
  0.0,
  33.3,
  'Green',
  'Favorável (Risco Baixo)',
  CASE
    -- Categorias de exigência/risco
    WHEN c.name IN ('EXIGÊNCIAS QUANTITATIVAS', 'RITMO DE TRABALHO', 'EXIGÊNCIAS COGNITIVAS', 'EXIGÊNCIAS EMOCIONAIS')
      THEN 'Manter boas práticas. Monitorar periodicamente para garantir a continuidade dos resultados positivos.'
    WHEN c.name IN ('BURNOUT', 'STRESS', 'SINTOMAS DEPRESSIVOS', 'PROBLEMAS EM DORMIR')
      THEN 'Indicadores saudáveis. Manter programas de bem-estar e acompanhamento preventivo.'
    WHEN c.name IN ('COMPORTAMENTOS OFENSIVOS')
      THEN 'Ambiente seguro. Manter canais de denúncia ativos e cultura de respeito.'
    WHEN c.name IN ('CONFLITO TRABALHO/FAMÍLIA')
      THEN 'Bom equilíbrio trabalho-vida. Manter políticas de flexibilidade.'
    WHEN c.name IN ('INSEGURANÇA LABORAL')
      THEN 'Colaboradores se sentem seguros. Manter comunicação transparente sobre estabilidade.'
    -- Categorias protetoras (invertidas)
    WHEN c.name IN ('INFLUÊNCIA NO TRABALHO', 'POSSIBILIDADES DE DESENVOLVIMENTO', 'SIGNIFICADO DO TRABALHO')
      THEN 'Excelente nível de autonomia e desenvolvimento. Manter e replicar como benchmark para outros setores.'
    WHEN c.name IN ('APOIO SOCIAL DE COLEGAS', 'APOIO SOCIAL DE SUPERIORES', 'COMUNIDADE SOCIAL NO TRABALHO')
      THEN 'Forte rede de apoio social. Manter iniciativas de integração e comunicação aberta.'
    WHEN c.name IN ('QUALIDADE DA LIDERANÇA', 'CONFIANÇA VERTICAL', 'CONFIANÇA HORIZONTAL')
      THEN 'Boa liderança e confiança organizacional. Manter programas de desenvolvimento de líderes.'
    WHEN c.name IN ('RECOMPENSAS', 'JUSTIÇA E RESPEITO', 'TRANSPARÊNCIA DO PAPEL LABORAL')
      THEN 'Colaboradores se sentem valorizados. Manter práticas de reconhecimento e clareza de papéis.'
    ELSE 'Situação favorável. Manter monitoramento regular e boas práticas vigentes.'
  END
FROM categories c;

-- Amarelo (Intermediário) para todas as categorias
INSERT INTO risk_classifications (category_id, min_score, max_score, risk_category, risk_level, action_required)
SELECT
  c.id,
  33.4,
  66.6,
  'Yellow',
  'Intermediário (Risco Médio)',
  CASE
    WHEN c.name IN ('EXIGÊNCIAS QUANTITATIVAS', 'RITMO DE TRABALHO', 'EXIGÊNCIAS COGNITIVAS', 'EXIGÊNCIAS EMOCIONAIS')
      THEN 'Atenção necessária. Avaliar redistribuição de carga de trabalho, pausas e recursos. Planejar intervenções preventivas.'
    WHEN c.name IN ('BURNOUT', 'STRESS', 'SINTOMAS DEPRESSIVOS', 'PROBLEMAS EM DORMIR')
      THEN 'Sinais de alerta. Implementar programas de gestão do estresse, grupos de apoio e acompanhamento periódico.'
    WHEN c.name IN ('COMPORTAMENTOS OFENSIVOS')
      THEN 'Atenção. Reforçar treinamentos sobre assédio e violência. Verificar eficácia dos canais de denúncia.'
    WHEN c.name IN ('CONFLITO TRABALHO/FAMÍLIA')
      THEN 'Equilibrio moderado. Avaliar política de horários flexíveis e carga de trabalho.'
    WHEN c.name IN ('INSEGURANÇA LABORAL')
      THEN 'Preocupação moderada. Melhorar comunicação sobre estabilidade e planos da empresa.'
    WHEN c.name IN ('INFLUÊNCIA NO TRABALHO', 'POSSIBILIDADES DE DESENVOLVIMENTO', 'SIGNIFICADO DO TRABALHO')
      THEN 'Nível intermediário de autonomia. Avaliar oportunidades de participação em decisões e crescimento profissional.'
    WHEN c.name IN ('APOIO SOCIAL DE COLEGAS', 'APOIO SOCIAL DE SUPERIORES', 'COMUNIDADE SOCIAL NO TRABALHO')
      THEN 'Apoio social parcial. Promover atividades de integração e melhorar canais de comunicação entre equipes.'
    WHEN c.name IN ('QUALIDADE DA LIDERANÇA', 'CONFIANÇA VERTICAL', 'CONFIANÇA HORIZONTAL')
      THEN 'Confiança e liderança precisam de reforço. Investir em treinamento de líderes e transparência na gestão.'
    WHEN c.name IN ('RECOMPENSAS', 'JUSTIÇA E RESPEITO', 'TRANSPARÊNCIA DO PAPEL LABORAL')
      THEN 'Percepção intermediária de reconhecimento. Revisar políticas de feedback, equidade e clareza de funções.'
    ELSE 'Situação intermediária. Planejar ações de melhoria e monitorar evolução nos próximos ciclos.'
  END
FROM categories c;

-- Vermelho (Risco) para todas as categorias
INSERT INTO risk_classifications (category_id, min_score, max_score, risk_category, risk_level, action_required)
SELECT
  c.id,
  66.7,
  100.0,
  'Red',
  'Risco (Risco Alto)',
  CASE
    WHEN c.name IN ('EXIGÊNCIAS QUANTITATIVAS', 'RITMO DE TRABALHO')
      THEN 'AÇÃO IMEDIATA: Reestruturar distribuição de tarefas, contratar reforço, limitar horas-extra. Intervenção obrigatória da gestão.'
    WHEN c.name IN ('EXIGÊNCIAS COGNITIVAS')
      THEN 'AÇÃO IMEDIATA: Simplificar processos, fornecer ferramentas adequadas, reduzir complexidade desnecessária.'
    WHEN c.name IN ('EXIGÊNCIAS EMOCIONAIS')
      THEN 'AÇÃO IMEDIATA: Disponibilizar apoio psicológico, rodízio em funções de alto impacto emocional, supervisão clínica.'
    WHEN c.name IN ('BURNOUT')
      THEN 'AÇÃO URGENTE: Risco de afastamento massivo. Intervenção psicológica individual e coletiva. Reavaliar condições de trabalho imediatamente.'
    WHEN c.name IN ('STRESS')
      THEN 'AÇÃO URGENTE: Implementar programa de gestão do estresse. Avaliar causas raiz e intervir nos fatores organizacionais.'
    WHEN c.name IN ('SINTOMAS DEPRESSIVOS')
      THEN 'AÇÃO URGENTE: Encaminhar para acompanhamento profissional de saúde mental. Acionar SESMT e programa de apoio ao empregado.'
    WHEN c.name IN ('PROBLEMAS EM DORMIR')
      THEN 'AÇÃO IMEDIATA: Avaliar escala de trabalho, turnos e sobrecarga. Orientar sobre higiene do sono.'
    WHEN c.name IN ('COMPORTAMENTOS OFENSIVOS')
      THEN 'AÇÃO URGENTE E OBRIGATÓRIA: Investigar ocorrências imediatamente. Acionar compliance, RH e jurídico. Risco legal e de saúde grave.'
    WHEN c.name IN ('CONFLITO TRABALHO/FAMÍLIA')
      THEN 'AÇÃO IMEDIATA: Revisar carga horária e políticas de flexibilidade. Avaliar impacto na retenção de talentos.'
    WHEN c.name IN ('INSEGURANÇA LABORAL')
      THEN 'AÇÃO IMEDIATA: Comunicação transparente da liderança sobre estabilidade. Programas de desenvolvimento e requalificação.'
    WHEN c.name IN ('SAÚDE GERAL')
      THEN 'AÇÃO URGENTE: Saúde dos colaboradores comprometida. Acionar medicina do trabalho, avaliar condições ergonômicas e psicossociais.'
    WHEN c.name IN ('INFLUÊNCIA NO TRABALHO', 'POSSIBILIDADES DE DESENVOLVIMENTO')
      THEN 'AÇÃO IMEDIATA: Colaboradores sem autonomia e crescimento. Reestruturar processos de participação e planos de carreira.'
    WHEN c.name IN ('SIGNIFICADO DO TRABALHO', 'COMPROMISSO COM O LOCAL DE TRABALHO', 'SATISFAÇÃO NO TRABALHO')
      THEN 'AÇÃO IMEDIATA: Risco de turnover elevado. Trabalhar propósito, reconhecimento e condições de trabalho.'
    WHEN c.name IN ('APOIO SOCIAL DE COLEGAS', 'APOIO SOCIAL DE SUPERIORES', 'COMUNIDADE SOCIAL NO TRABALHO')
      THEN 'AÇÃO IMEDIATA: Isolamento social detectado. Promover integração, mentoria e reuniões regulares de equipe.'
    WHEN c.name IN ('QUALIDADE DA LIDERANÇA')
      THEN 'AÇÃO IMEDIATA: Déficit grave de liderança. Programa urgente de desenvolvimento de gestores. Considerar mudanças na gestão.'
    WHEN c.name IN ('CONFIANÇA HORIZONTAL', 'CONFIANÇA VERTICAL')
      THEN 'AÇÃO IMEDIATA: Crise de confiança organizacional. Implementar transparência, comunicação aberta e mediação de conflitos.'
    WHEN c.name IN ('RECOMPENSAS', 'JUSTIÇA E RESPEITO')
      THEN 'AÇÃO IMEDIATA: Percepção de injustiça grave. Revisar políticas de remuneração, promoção e tratamento equitativo.'
    WHEN c.name IN ('TRANSPARÊNCIA DO PAPEL LABORAL', 'PREVISIBILIDADE')
      THEN 'AÇÃO IMEDIATA: Colaboradores sem clareza de papel. Redefinir responsabilidades e melhorar comunicação organizacional.'
    WHEN c.name IN ('CONFLITOS LABORAIS')
      THEN 'AÇÃO IMEDIATA: Alto nível de conflitos. Mediação profissional, revisão de processos e alinhamento de expectativas.'
    WHEN c.name IN ('AUTO-EFICÁCIA')
      THEN 'AÇÃO IMEDIATA: Baixa autoconfiança dos colaboradores. Programas de capacitação, feedback positivo e mentoria.'
    ELSE 'AÇÃO IMEDIATA: Intervenção obrigatória. Acionar gestão, RH e saúde ocupacional para diagnóstico e plano de ação.'
  END
FROM categories c;

-- ============================================
-- 3. RLS
-- ============================================
ALTER TABLE risk_classifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Leitura publica risk_classifications" ON risk_classifications FOR SELECT USING (true);

-- ============================================
-- 4. VIEW ATUALIZADA: vw_respostas_completas
-- Agora inclui o semáforo COPSOQ + ação recomendada
-- ============================================
CREATE OR REPLACE VIEW vw_respostas_completas AS
SELECT
  e.id          AS employee_id,
  e.name        AS employee_name,
  d.id          AS department_id,
  d.name        AS department_name,
  s.id          AS submission_id,
  s.submitted_at,
  q.question_number,
  q.question_text,
  q.is_inverted,
  c.id          AS category_id,
  c.name        AS category_name,
  a.score       AS score_original,

  -- Score convertido 0-100
  CASE
    WHEN q.is_inverted = false THEN ROUND(((a.score - 1)::NUMERIC / 4) * 100)
    WHEN q.is_inverted = true  THEN ROUND(((5 - a.score)::NUMERIC / 4) * 100)
  END AS score_0_100,

  -- Semáforo (da tabela risk_classifications)
  rc.risk_category AS semaforo_cor,
  rc.risk_level    AS semaforo_nivel,
  rc.action_required AS acao_recomendada

FROM answers a
  JOIN submissions s ON a.submission_id = s.id
  JOIN employees e   ON s.employee_id = e.id
  JOIN departments d ON e.department_id = d.id
  JOIN questions q   ON a.question_id = q.id
  JOIN categories c  ON q.category_id = c.id
  LEFT JOIN risk_classifications rc
    ON rc.category_id = c.id
   AND (
     CASE
       WHEN q.is_inverted = false THEN ROUND(((a.score - 1)::NUMERIC / 4) * 100)
       WHEN q.is_inverted = true  THEN ROUND(((5 - a.score)::NUMERIC / 4) * 100)
     END
   ) >= rc.min_score
   AND (
     CASE
       WHEN q.is_inverted = false THEN ROUND(((a.score - 1)::NUMERIC / 4) * 100)
       WHEN q.is_inverted = true  THEN ROUND(((5 - a.score)::NUMERIC / 4) * 100)
     END
   ) <= rc.max_score;

-- ============================================
-- 5. VIEW ATUALIZADA: vw_media_por_categoria_setor
-- Média por categoria/setor COM semáforo e ação
-- ============================================
CREATE OR REPLACE VIEW vw_media_por_categoria_setor AS
WITH medias AS (
  SELECT
    d.id   AS department_id,
    d.name AS department_name,
    c.id   AS category_id,
    c.name AS category_name,
    ROUND(AVG(
      CASE
        WHEN q.is_inverted = false THEN ((a.score - 1)::NUMERIC / 4) * 100
        WHEN q.is_inverted = true  THEN ((5 - a.score)::NUMERIC / 4) * 100
      END
    ), 1) AS score_medio,
    COUNT(DISTINCT s.id) AS total_submissions,
    COUNT(DISTINCT s.employee_id) AS total_respondentes
  FROM answers a
    JOIN submissions s ON a.submission_id = s.id
    JOIN employees e   ON s.employee_id = e.id
    JOIN departments d ON e.department_id = d.id
    JOIN questions q   ON a.question_id = q.id
    JOIN categories c  ON q.category_id = c.id
  GROUP BY d.id, d.name, c.id, c.name
)
SELECT
  m.department_id,
  m.department_name,
  m.category_id,
  m.category_name,
  m.score_medio,
  m.total_submissions,
  m.total_respondentes,

  -- Semáforo baseado na média
  rc.risk_category AS semaforo_cor,
  rc.risk_level    AS semaforo_nivel,
  rc.action_required AS acao_recomendada,

  -- Cor hex para o frontend
  CASE rc.risk_category
    WHEN 'Green'  THEN '#22c55e'
    WHEN 'Yellow' THEN '#eab308'
    WHEN 'Red'    THEN '#ef4444'
  END AS cor_hex

FROM medias m
  LEFT JOIN risk_classifications rc
    ON rc.category_id = m.category_id
   AND m.score_medio >= rc.min_score
   AND m.score_medio <= rc.max_score;
