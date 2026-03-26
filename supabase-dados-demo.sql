-- =============================================
-- M.A.P.A. — Dados de Demonstração
-- 3 empresas, 15 setores, 45 colaboradores, respostas simuladas
-- Execute APÓS os 3 scripts anteriores
-- =============================================

-- ============================================
-- 1. EMPRESAS
-- ============================================
INSERT INTO empresas (nome, cnpj) VALUES
  ('Hospital São Lucas', '12.345.678/0001-01'),
  ('Indústria MetalSul', '23.456.789/0001-02'),
  ('Escola Futuro Brilhante', '34.567.890/0001-03')
ON CONFLICT (cnpj) DO NOTHING;

-- ============================================
-- 2. SETORES (departments)
-- ============================================

-- Hospital São Lucas (5 setores)
INSERT INTO departments (empresa_id, name) VALUES
  ((SELECT id FROM empresas WHERE cnpj = '12.345.678/0001-01'), 'Pediatria'),
  ((SELECT id FROM empresas WHERE cnpj = '12.345.678/0001-01'), 'Emergência'),
  ((SELECT id FROM empresas WHERE cnpj = '12.345.678/0001-01'), 'Recepção'),
  ((SELECT id FROM empresas WHERE cnpj = '12.345.678/0001-01'), 'Enfermagem UTI'),
  ((SELECT id FROM empresas WHERE cnpj = '12.345.678/0001-01'), 'Administrativo');

-- Indústria MetalSul (5 setores)
INSERT INTO departments (empresa_id, name) VALUES
  ((SELECT id FROM empresas WHERE cnpj = '23.456.789/0001-02'), 'Produção'),
  ((SELECT id FROM empresas WHERE cnpj = '23.456.789/0001-02'), 'Logística'),
  ((SELECT id FROM empresas WHERE cnpj = '23.456.789/0001-02'), 'Qualidade'),
  ((SELECT id FROM empresas WHERE cnpj = '23.456.789/0001-02'), 'Manutenção'),
  ((SELECT id FROM empresas WHERE cnpj = '23.456.789/0001-02'), 'RH');

-- Escola Futuro Brilhante (5 setores)
INSERT INTO departments (empresa_id, name) VALUES
  ((SELECT id FROM empresas WHERE cnpj = '34.567.890/0001-03'), 'Professores Fundamental'),
  ((SELECT id FROM empresas WHERE cnpj = '34.567.890/0001-03'), 'Professores Médio'),
  ((SELECT id FROM empresas WHERE cnpj = '34.567.890/0001-03'), 'Coordenação Pedagógica'),
  ((SELECT id FROM empresas WHERE cnpj = '34.567.890/0001-03'), 'Secretaria'),
  ((SELECT id FROM empresas WHERE cnpj = '34.567.890/0001-03'), 'Serviços Gerais');

-- ============================================
-- 3. COLABORADORES (3 por setor = 45 total)
-- ============================================

-- HOSPITAL SÃO LUCAS
-- Pediatria
INSERT INTO employees (name, department_id) VALUES
  ('Ana Silva',     (SELECT id FROM departments WHERE name = 'Pediatria' LIMIT 1)),
  ('Bruno Costa',   (SELECT id FROM departments WHERE name = 'Pediatria' LIMIT 1)),
  ('Carla Mendes',  (SELECT id FROM departments WHERE name = 'Pediatria' LIMIT 1));
-- Emergência
INSERT INTO employees (name, department_id) VALUES
  ('Diego Oliveira', (SELECT id FROM departments WHERE name = 'Emergência' LIMIT 1)),
  ('Elena Ramos',    (SELECT id FROM departments WHERE name = 'Emergência' LIMIT 1)),
  ('Felipe Santos',  (SELECT id FROM departments WHERE name = 'Emergência' LIMIT 1));
-- Recepção
INSERT INTO employees (name, department_id) VALUES
  ('Gabriela Lima',  (SELECT id FROM departments WHERE name = 'Recepção' LIMIT 1)),
  ('Hugo Ferreira',  (SELECT id FROM departments WHERE name = 'Recepção' LIMIT 1)),
  ('Isabela Rocha',  (SELECT id FROM departments WHERE name = 'Recepção' LIMIT 1));
-- Enfermagem UTI
INSERT INTO employees (name, department_id) VALUES
  ('João Almeida',   (SELECT id FROM departments WHERE name = 'Enfermagem UTI' LIMIT 1)),
  ('Karen Souza',    (SELECT id FROM departments WHERE name = 'Enfermagem UTI' LIMIT 1)),
  ('Lucas Barbosa',  (SELECT id FROM departments WHERE name = 'Enfermagem UTI' LIMIT 1));
-- Administrativo
INSERT INTO employees (name, department_id) VALUES
  ('Marina Dias',    (SELECT id FROM departments WHERE name = 'Administrativo' LIMIT 1)),
  ('Nelson Pires',   (SELECT id FROM departments WHERE name = 'Administrativo' LIMIT 1)),
  ('Olívia Martins', (SELECT id FROM departments WHERE name = 'Administrativo' LIMIT 1));

-- INDÚSTRIA METALSUL
-- Produção
INSERT INTO employees (name, department_id) VALUES
  ('Paulo Ribeiro',   (SELECT id FROM departments WHERE name = 'Produção' LIMIT 1)),
  ('Queila Nunes',    (SELECT id FROM departments WHERE name = 'Produção' LIMIT 1)),
  ('Rafael Teixeira', (SELECT id FROM departments WHERE name = 'Produção' LIMIT 1));
-- Logística
INSERT INTO employees (name, department_id) VALUES
  ('Sandra Moreira',  (SELECT id FROM departments WHERE name = 'Logística' LIMIT 1)),
  ('Thiago Cunha',    (SELECT id FROM departments WHERE name = 'Logística' LIMIT 1)),
  ('Úrsula Cardoso',  (SELECT id FROM departments WHERE name = 'Logística' LIMIT 1));
-- Qualidade
INSERT INTO employees (name, department_id) VALUES
  ('Vinícius Araujo', (SELECT id FROM departments WHERE name = 'Qualidade' LIMIT 1)),
  ('Wanda Gomes',     (SELECT id FROM departments WHERE name = 'Qualidade' LIMIT 1)),
  ('Xavier Lopes',    (SELECT id FROM departments WHERE name = 'Qualidade' LIMIT 1));
-- Manutenção
INSERT INTO employees (name, department_id) VALUES
  ('Yara Pereira',    (SELECT id FROM departments WHERE name = 'Manutenção' LIMIT 1)),
  ('Zé Carlos',       (SELECT id FROM departments WHERE name = 'Manutenção' LIMIT 1)),
  ('Amanda Freitas',  (SELECT id FROM departments WHERE name = 'Manutenção' LIMIT 1));
-- RH
INSERT INTO employees (name, department_id) VALUES
  ('Beatriz Campos',  (SELECT id FROM departments WHERE name = 'RH' LIMIT 1)),
  ('Caio Monteiro',   (SELECT id FROM departments WHERE name = 'RH' LIMIT 1)),
  ('Débora Vieira',   (SELECT id FROM departments WHERE name = 'RH' LIMIT 1));

-- ESCOLA FUTURO BRILHANTE
-- Professores Fundamental
INSERT INTO employees (name, department_id) VALUES
  ('Eduardo Bastos',  (SELECT id FROM departments WHERE name = 'Professores Fundamental' LIMIT 1)),
  ('Fátima Correia',  (SELECT id FROM departments WHERE name = 'Professores Fundamental' LIMIT 1)),
  ('Gustavo Reis',    (SELECT id FROM departments WHERE name = 'Professores Fundamental' LIMIT 1));
-- Professores Médio
INSERT INTO employees (name, department_id) VALUES
  ('Helena Duarte',   (SELECT id FROM departments WHERE name = 'Professores Médio' LIMIT 1)),
  ('Igor Machado',    (SELECT id FROM departments WHERE name = 'Professores Médio' LIMIT 1)),
  ('Juliana Castro',  (SELECT id FROM departments WHERE name = 'Professores Médio' LIMIT 1));
-- Coordenação Pedagógica
INSERT INTO employees (name, department_id) VALUES
  ('Kleber Fonseca',  (SELECT id FROM departments WHERE name = 'Coordenação Pedagógica' LIMIT 1)),
  ('Letícia Andrade', (SELECT id FROM departments WHERE name = 'Coordenação Pedagógica' LIMIT 1)),
  ('Marcos Tavares',  (SELECT id FROM departments WHERE name = 'Coordenação Pedagógica' LIMIT 1));
-- Secretaria
INSERT INTO employees (name, department_id) VALUES
  ('Natália Borges',  (SELECT id FROM departments WHERE name = 'Secretaria' LIMIT 1)),
  ('Otávio Pinto',    (SELECT id FROM departments WHERE name = 'Secretaria' LIMIT 1)),
  ('Priscila Luz',    (SELECT id FROM departments WHERE name = 'Secretaria' LIMIT 1));
-- Serviços Gerais
INSERT INTO employees (name, department_id) VALUES
  ('Renato Melo',     (SELECT id FROM departments WHERE name = 'Serviços Gerais' LIMIT 1)),
  ('Simone Azevedo',  (SELECT id FROM departments WHERE name = 'Serviços Gerais' LIMIT 1)),
  ('Tatiana Coelho',  (SELECT id FROM departments WHERE name = 'Serviços Gerais' LIMIT 1));

-- ============================================
-- 4. RESPOSTAS SIMULADAS
-- Cada colaborador responde as 76 perguntas
-- Perfis realistas por setor:
--
-- HOSPITAL:
--   Emergência/UTI: alto risco (scores 4-5 em exigências, burnout)
--   Pediatria: risco médio
--   Recepção: risco baixo-médio
--   Administrativo: risco baixo
--
-- INDÚSTRIA:
--   Produção: alto risco (ritmo, exigências físicas)
--   Logística: risco alto
--   Manutenção: risco médio
--   Qualidade: risco baixo-médio
--   RH: risco baixo
--
-- ESCOLA:
--   Professores: risco médio-alto (exigências emocionais)
--   Coordenação: risco médio
--   Secretaria: risco baixo
--   Serviços Gerais: risco médio (insegurança)
-- ============================================

-- Função auxiliar para gerar respostas
-- Recebe o employee name e um array de 76 scores
CREATE OR REPLACE FUNCTION insert_survey(p_employee_name TEXT, p_scores INTEGER[])
RETURNS VOID AS $$
DECLARE
  v_employee_id UUID;
  v_submission_id UUID;
  v_question RECORD;
  v_idx INTEGER := 1;
BEGIN
  SELECT id INTO v_employee_id FROM employees WHERE name = p_employee_name LIMIT 1;
  IF v_employee_id IS NULL THEN RETURN; END IF;

  INSERT INTO submissions (employee_id) VALUES (v_employee_id) RETURNING id INTO v_submission_id;

  FOR v_question IN SELECT id FROM questions ORDER BY question_number LOOP
    INSERT INTO answers (submission_id, question_id, score)
    VALUES (v_submission_id, v_question.id, p_scores[v_idx]);
    v_idx := v_idx + 1;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- HOSPITAL SÃO LUCAS - Respostas
-- ============================================

-- EMERGÊNCIA (alto risco: burnout, stress, exigências altas)
SELECT insert_survey('Diego Oliveira', ARRAY[
  5,5,5,  5,  5,4,4,  5,  2,1,2,2,  3,3,3,  2,2,  4,4,4,  2,2,2,  4,4,4,  2,2,2,  2,2,2,  3,3,2,  2,2,2,2,  3,3,3,  2,3,4,  2,2,2,  3,3,  4,4,4,  3,3,  3,3,3,3,  4,  3,  5,5,4,  4,4,  5,5,  4,4,  4,4,  2,1,1,1
]);
SELECT insert_survey('Elena Ramos', ARRAY[
  4,5,4,  5,  4,4,5,  5,  2,2,1,2,  3,2,3,  2,3,  3,4,3,  2,3,2,  4,5,4,  3,2,2,  2,2,3,  3,2,2,  2,3,2,3,  4,3,3,  3,3,4,  3,2,3,  3,3,  4,4,3,  3,3,  3,3,3,3,  4,  3,  4,4,5,  5,4,  4,5,  4,5,  4,3,  2,1,1,1
]);
SELECT insert_survey('Felipe Santos', ARRAY[
  5,4,5,  4,  5,3,4,  4,  1,2,2,1,  2,3,2,  2,2,  3,3,3,  3,2,2,  3,4,3,  2,3,2,  1,2,2,  2,3,2,  3,2,2,2,  4,4,2,  2,2,3,  3,3,2,  3,3,  3,3,3,  2,2,  2,3,2,3,  5,  2,  4,5,4,  4,3,  5,4,  5,4,  4,4,  3,2,2,1
]);

-- ENFERMAGEM UTI (alto risco similar)
SELECT insert_survey('João Almeida', ARRAY[
  5,4,5,  5,  5,3,4,  5,  2,1,1,2,  3,3,2,  2,2,  3,4,4,  2,2,3,  4,4,5,  2,2,3,  2,1,2,  3,3,2,  2,2,3,2,  3,4,3,  2,3,4,  3,2,2,  3,3,  4,3,4,  3,3,  3,3,2,3,  4,  3,  5,4,4,  4,5,  5,5,  5,4,  4,4,  3,2,1,1
]);
SELECT insert_survey('Karen Souza', ARRAY[
  4,5,4,  4,  4,4,3,  5,  2,2,2,1,  2,3,3,  3,2,  4,3,4,  3,2,2,  3,4,4,  3,2,2,  2,2,2,  3,2,3,  3,2,2,3,  3,3,2,  2,2,4,  2,3,2,  4,3,  3,4,4,  3,2,  3,2,3,3,  3,  3,  4,5,4,  4,4,  4,4,  4,5,  3,4,  2,1,1,1
]);
SELECT insert_survey('Lucas Barbosa', ARRAY[
  5,5,5,  5,  5,4,5,  4,  1,1,2,1,  3,2,3,  2,2,  3,3,3,  2,2,2,  4,5,4,  2,2,2,  1,1,2,  2,2,2,  2,2,2,2,  4,4,3,  2,3,4,  2,2,2,  3,3,  3,4,3,  3,3,  2,2,2,2,  5,  2,  5,5,5,  5,4,  5,5,  5,5,  5,4,  4,3,2,1
]);

-- PEDIATRIA (risco médio)
SELECT insert_survey('Ana Silva', ARRAY[
  3,3,2,  3,  4,3,3,  4,  3,2,3,3,  4,4,3,  3,3,  4,4,4,  3,3,3,  3,3,2,  3,3,3,  3,3,3,  4,3,3,  3,3,3,3,  2,2,3,  3,3,2,  3,3,3,  3,3,  3,3,3,  3,3,  3,3,3,3,  3,  3,  3,3,3,  3,2,  3,3,  3,3,  2,2,  1,1,1,1
]);
SELECT insert_survey('Bruno Costa', ARRAY[
  3,4,3,  3,  3,3,4,  3,  3,3,2,3,  3,4,4,  3,4,  4,4,3,  3,4,3,  2,3,3,  3,4,3,  3,3,4,  4,4,3,  4,3,4,3,  2,3,3,  3,4,2,  3,3,4,  4,3,  4,3,4,  4,3,  4,3,3,4,  2,  4,  3,2,3,  2,3,  3,2,  2,3,  2,2,  1,1,1,1
]);
SELECT insert_survey('Carla Mendes', ARRAY[
  2,3,3,  4,  4,3,3,  4,  3,2,3,2,  4,3,4,  3,3,  3,4,4,  4,3,3,  3,3,3,  4,3,3,  3,4,3,  3,4,4,  3,4,3,3,  3,2,3,  4,3,2,  4,3,3,  3,4,  3,4,3,  3,4,  3,4,4,3,  3,  3,  3,3,2,  3,3,  3,3,  3,2,  3,2,  1,1,1,1
]);

-- RECEPÇÃO (risco baixo-médio)
SELECT insert_survey('Gabriela Lima', ARRAY[
  2,2,1,  2,  3,2,2,  2,  3,3,3,3,  4,4,4,  4,4,  4,5,5,  4,4,4,  2,2,2,  4,4,3,  4,4,3,  4,4,4,  4,4,4,4,  2,2,4,  4,4,2,  4,4,4,  4,4,  4,4,4,  4,4,  4,4,4,4,  2,  4,  2,2,1,  2,1,  2,2,  2,2,  1,1,  1,1,1,1
]);
SELECT insert_survey('Hugo Ferreira', ARRAY[
  2,3,2,  2,  3,2,2,  3,  3,3,4,3,  3,4,3,  3,4,  4,4,4,  4,4,3,  2,3,2,  4,3,4,  3,4,3,  4,3,4,  4,3,4,3,  2,2,4,  4,3,2,  4,3,4,  3,4,  4,3,4,  4,3,  4,4,3,4,  2,  4,  2,2,2,  2,2,  2,1,  2,2,  2,1,  1,1,1,1
]);
SELECT insert_survey('Isabela Rocha', ARRAY[
  1,2,2,  3,  2,2,3,  2,  4,3,3,4,  4,4,4,  4,3,  5,4,4,  4,4,4,  2,2,3,  4,4,3,  4,3,4,  4,4,4,  4,4,3,4,  2,2,4,  4,4,2,  4,4,3,  4,4,  4,4,4,  4,4,  4,4,4,4,  1,  4,  1,2,2,  1,2,  1,2,  1,2,  1,2,  1,1,1,1
]);

-- ADMINISTRATIVO (risco baixo)
SELECT insert_survey('Marina Dias', ARRAY[
  1,1,1,  2,  2,2,2,  1,  4,4,4,4,  4,5,5,  4,5,  5,5,5,  5,5,5,  1,1,1,  5,5,4,  5,5,4,  5,5,5,  5,5,5,5,  1,1,5,  5,5,1,  5,5,5,  5,5,  5,5,5,  5,5,  5,5,5,5,  1,  5,  1,1,1,  1,1,  1,1,  1,1,  1,1,  1,1,1,1
]);
SELECT insert_survey('Nelson Pires', ARRAY[
  2,1,1,  2,  3,2,2,  2,  4,4,3,4,  4,4,5,  4,4,  4,5,4,  4,5,4,  2,1,2,  4,4,4,  4,4,4,  4,4,4,  4,4,5,4,  2,1,4,  4,5,1,  4,4,4,  4,4,  5,4,4,  4,5,  4,4,4,4,  1,  4,  1,2,1,  1,1,  1,1,  1,1,  1,1,  1,1,1,1
]);
SELECT insert_survey('Olívia Martins', ARRAY[
  1,2,1,  1,  2,2,1,  1,  5,4,4,5,  5,5,4,  5,4,  5,5,5,  5,4,5,  1,2,1,  5,4,5,  4,5,5,  5,5,4,  5,4,5,5,  1,1,5,  5,5,1,  5,5,4,  5,5,  5,5,5,  5,5,  5,5,5,5,  1,  5,  1,1,1,  1,1,  1,1,  1,1,  1,1,  1,1,1,1
]);

-- ============================================
-- INDÚSTRIA METALSUL - Respostas
-- ============================================

-- PRODUÇÃO (alto risco: ritmo, exigências, burnout)
SELECT insert_survey('Paulo Ribeiro', ARRAY[
  5,5,5,  5,  4,3,3,  3,  1,1,1,1,  2,2,2,  2,2,  3,3,3,  2,2,2,  4,4,4,  2,2,2,  2,1,1,  2,2,2,  2,2,2,2,  4,4,2,  2,2,4,  2,2,2,  3,2,  2,2,2,  2,2,  2,2,2,2,  5,  2,  4,4,5,  4,4,  5,4,  4,4,  3,3,  3,2,2,1
]);
SELECT insert_survey('Queila Nunes', ARRAY[
  4,4,5,  5,  5,3,4,  4,  2,1,2,1,  2,3,2,  2,3,  3,3,2,  2,3,2,  4,5,4,  2,3,2,  1,2,2,  3,2,2,  2,3,2,2,  4,3,2,  3,2,4,  2,2,3,  3,3,  3,2,3,  2,3,  3,2,3,2,  4,  2,  5,4,4,  3,4,  4,4,  4,3,  3,3,  2,2,1,1
]);
SELECT insert_survey('Rafael Teixeira', ARRAY[
  5,4,4,  4,  4,2,3,  3,  1,1,1,2,  3,2,3,  2,2,  2,3,3,  2,2,3,  5,4,5,  2,2,3,  2,1,2,  2,3,3,  3,2,2,3,  3,4,2,  2,3,4,  3,2,2,  2,3,  3,3,2,  3,2,  3,3,2,3,  4,  3,  4,5,4,  4,3,  4,5,  4,4,  4,3,  3,2,2,2
]);

-- LOGÍSTICA (risco alto)
SELECT insert_survey('Sandra Moreira', ARRAY[
  4,4,4,  4,  3,3,3,  3,  2,2,2,2,  3,3,3,  3,3,  3,3,3,  3,3,2,  3,4,3,  3,3,2,  2,3,2,  3,3,3,  3,3,3,3,  3,3,3,  3,3,3,  3,3,3,  3,3,  3,3,3,  3,3,  3,3,3,3,  4,  3,  4,3,4,  3,3,  4,4,  3,4,  3,3,  2,1,1,1
]);
SELECT insert_survey('Thiago Cunha', ARRAY[
  5,4,5,  5,  4,3,4,  4,  2,1,2,1,  3,2,2,  2,2,  3,3,3,  2,2,2,  4,4,4,  2,2,2,  2,2,2,  3,2,2,  2,2,2,2,  4,4,2,  2,2,4,  2,2,2,  3,2,  2,2,2,  2,2,  2,2,2,2,  5,  2,  5,5,4,  4,4,  5,4,  4,4,  4,3,  2,1,1,1
]);
SELECT insert_survey('Úrsula Cardoso', ARRAY[
  4,5,4,  4,  4,3,3,  3,  2,2,1,2,  3,3,2,  2,3,  3,4,3,  3,2,3,  4,3,4,  3,2,3,  2,3,2,  3,3,2,  3,2,3,2,  3,3,3,  3,3,3,  3,2,3,  3,3,  3,3,3,  3,2,  3,3,3,3,  4,  3,  4,4,3,  3,3,  4,3,  4,3,  3,3,  2,1,1,1
]);

-- QUALIDADE (risco baixo-médio)
SELECT insert_survey('Vinícius Araujo', ARRAY[
  2,2,2,  3,  3,3,3,  2,  3,3,3,3,  4,4,4,  4,4,  4,4,4,  4,4,4,  2,2,2,  4,4,3,  4,3,4,  4,4,4,  4,4,4,4,  2,2,4,  4,4,2,  4,4,3,  4,4,  4,4,4,  4,4,  4,4,4,4,  2,  4,  2,2,2,  2,2,  2,2,  2,2,  2,1,  1,1,1,1
]);
SELECT insert_survey('Wanda Gomes', ARRAY[
  2,3,2,  2,  3,3,2,  2,  4,3,3,4,  4,3,4,  3,4,  4,4,4,  3,4,4,  2,3,2,  3,4,3,  4,3,4,  4,4,3,  3,4,4,3,  2,2,4,  4,4,2,  3,4,4,  4,3,  4,4,3,  3,4,  4,3,4,4,  2,  4,  2,2,2,  2,2,  2,2,  2,2,  1,2,  1,1,1,1
]);
SELECT insert_survey('Xavier Lopes', ARRAY[
  3,2,2,  3,  4,3,3,  3,  3,3,3,3,  4,4,3,  3,3,  4,4,4,  4,3,4,  3,2,3,  3,4,3,  3,4,3,  4,3,4,  4,3,3,4,  2,3,3,  3,4,2,  4,3,4,  3,4,  3,3,4,  4,3,  4,3,4,3,  3,  3,  2,3,2,  2,2,  3,2,  2,3,  2,2,  1,1,1,1
]);

-- MANUTENÇÃO (risco médio)
SELECT insert_survey('Yara Pereira', ARRAY[
  3,3,4,  4,  3,2,3,  3,  2,2,3,2,  3,3,3,  3,3,  3,3,3,  3,3,3,  3,3,3,  3,3,3,  3,3,3,  3,3,3,  3,3,3,3,  3,3,3,  3,3,3,  3,3,3,  3,3,  3,3,3,  3,3,  3,3,3,3,  3,  3,  3,3,3,  3,3,  3,3,  3,3,  2,2,  2,1,1,1
]);
SELECT insert_survey('Zé Carlos', ARRAY[
  4,3,4,  4,  3,3,3,  3,  2,2,2,2,  3,3,2,  2,3,  3,3,3,  2,3,3,  3,4,3,  3,2,3,  2,3,2,  3,3,2,  3,2,3,3,  3,3,3,  3,3,3,  3,3,2,  3,3,  3,3,3,  3,3,  3,3,3,3,  3,  3,  3,4,3,  3,3,  3,4,  3,3,  3,2,  2,2,1,1
]);
SELECT insert_survey('Amanda Freitas', ARRAY[
  3,4,3,  3,  3,3,4,  3,  3,2,2,3,  4,3,3,  3,3,  3,4,3,  3,3,3,  3,3,3,  3,3,3,  3,2,3,  4,3,3,  3,3,3,3,  3,3,3,  3,3,3,  3,3,3,  3,3,  3,4,3,  3,3,  3,3,3,3,  3,  3,  3,3,3,  3,3,  3,3,  3,3,  2,2,  1,1,1,1
]);

-- RH (risco baixo)
SELECT insert_survey('Beatriz Campos', ARRAY[
  1,2,1,  2,  2,3,2,  2,  4,4,4,4,  5,5,4,  4,5,  5,5,5,  5,4,5,  1,2,1,  5,5,4,  5,4,5,  5,5,5,  5,5,4,5,  1,1,5,  5,5,1,  5,5,4,  5,4,  5,5,5,  5,5,  5,5,5,5,  1,  5,  1,1,1,  1,1,  1,1,  1,1,  1,1,  1,1,1,1
]);
SELECT insert_survey('Caio Monteiro', ARRAY[
  2,1,2,  2,  3,2,2,  1,  4,4,4,3,  4,5,4,  4,4,  4,5,5,  4,5,4,  2,1,2,  4,4,5,  4,5,4,  5,4,4,  4,5,4,4,  2,1,4,  4,4,2,  4,4,4,  4,4,  4,5,4,  4,4,  4,4,5,4,  1,  4,  1,1,2,  1,1,  1,2,  1,2,  1,1,  1,1,1,1
]);
SELECT insert_survey('Débora Vieira', ARRAY[
  1,1,1,  1,  2,2,2,  1,  5,5,4,5,  5,4,5,  5,5,  5,4,5,  5,5,5,  1,1,1,  5,5,5,  5,5,5,  5,5,5,  5,5,5,5,  1,1,5,  5,5,1,  5,5,5,  5,5,  5,5,5,  5,5,  5,5,5,5,  1,  5,  1,1,1,  1,1,  1,1,  1,1,  1,1,  1,1,1,1
]);

-- ============================================
-- ESCOLA FUTURO BRILHANTE - Respostas
-- ============================================

-- PROFESSORES FUNDAMENTAL (risco médio-alto: exigências emocionais)
SELECT insert_survey('Eduardo Bastos', ARRAY[
  3,3,3,  3,  4,4,3,  5,  3,2,2,3,  4,4,3,  3,3,  4,4,3,  3,3,3,  3,3,3,  3,3,3,  3,3,3,  4,3,3,  3,3,3,3,  3,3,3,  3,3,3,  3,3,3,  4,3,  4,4,4,  3,4,  4,3,3,3,  3,  3,  3,3,4,  3,3,  3,4,  3,3,  3,3,  2,1,1,1
]);
SELECT insert_survey('Fátima Correia', ARRAY[
  4,3,4,  4,  4,3,4,  5,  2,2,2,2,  3,3,3,  3,3,  3,3,4,  3,2,3,  3,3,4,  3,3,3,  3,2,3,  3,3,3,  3,3,2,3,  3,3,3,  3,3,3,  3,3,2,  3,3,  3,3,3,  3,3,  3,3,3,3,  4,  3,  4,3,4,  4,3,  4,4,  4,3,  3,3,  2,1,1,1
]);
SELECT insert_survey('Gustavo Reis', ARRAY[
  3,4,3,  3,  4,4,3,  4,  3,2,3,2,  4,4,4,  3,3,  4,3,4,  3,3,3,  3,3,3,  3,4,3,  3,3,3,  4,4,3,  3,4,3,4,  3,2,3,  3,4,3,  3,3,3,  3,4,  3,4,3,  4,3,  3,4,3,4,  3,  4,  3,3,3,  3,3,  3,3,  3,3,  2,3,  1,1,1,1
]);

-- PROFESSORES MÉDIO (risco médio-alto)
SELECT insert_survey('Helena Duarte', ARRAY[
  3,4,3,  4,  4,4,4,  5,  3,2,2,3,  3,4,4,  3,3,  3,4,4,  3,3,3,  3,3,4,  3,3,3,  2,3,3,  3,4,3,  3,3,3,3,  3,3,3,  3,3,3,  3,3,3,  3,3,  4,3,4,  3,3,  4,3,3,4,  3,  3,  3,4,3,  3,3,  3,3,  3,4,  3,2,  1,1,1,1
]);
SELECT insert_survey('Igor Machado', ARRAY[
  4,3,4,  4,  3,4,4,  4,  2,2,3,2,  4,3,3,  3,3,  3,3,3,  2,3,3,  4,3,3,  3,3,2,  2,3,2,  3,3,3,  3,2,3,3,  3,3,3,  3,3,3,  3,2,3,  3,3,  3,3,3,  3,3,  3,3,3,3,  4,  3,  4,3,4,  4,3,  4,3,  3,4,  3,3,  2,2,1,1
]);
SELECT insert_survey('Juliana Castro', ARRAY[
  3,3,3,  3,  4,3,3,  5,  3,3,2,3,  4,4,4,  3,4,  4,4,3,  3,4,3,  3,3,3,  4,3,3,  3,3,3,  4,3,4,  4,3,3,4,  2,3,4,  3,4,2,  4,3,4,  4,3,  4,4,3,  4,4,  4,3,4,3,  2,  4,  3,3,3,  2,3,  3,3,  2,3,  2,2,  1,1,1,1
]);

-- COORDENAÇÃO PEDAGÓGICA (risco médio)
SELECT insert_survey('Kleber Fonseca', ARRAY[
  3,3,2,  3,  3,4,3,  3,  3,3,3,3,  4,4,4,  3,4,  4,4,4,  4,4,3,  2,3,2,  4,3,4,  4,3,4,  4,4,4,  4,4,4,4,  2,2,4,  4,4,2,  4,4,4,  4,4,  4,4,4,  4,4,  4,3,4,4,  2,  4,  2,2,2,  2,2,  2,2,  2,2,  1,2,  1,1,1,1
]);
SELECT insert_survey('Letícia Andrade', ARRAY[
  2,3,2,  3,  3,3,3,  3,  4,3,3,3,  4,4,4,  4,3,  4,4,4,  4,3,4,  2,2,3,  4,4,3,  3,4,3,  4,4,3,  4,3,4,3,  2,2,4,  4,3,2,  4,3,3,  3,4,  4,4,3,  3,4,  4,4,3,4,  2,  4,  2,3,2,  2,2,  2,2,  2,3,  2,1,  1,1,1,1
]);
SELECT insert_survey('Marcos Tavares', ARRAY[
  2,2,3,  3,  4,3,4,  3,  3,3,3,4,  4,3,4,  3,4,  4,4,4,  3,4,4,  3,2,2,  3,4,3,  4,3,3,  4,4,4,  3,4,3,4,  2,2,4,  3,4,2,  3,4,4,  4,3,  4,3,4,  4,3,  4,4,4,3,  2,  4,  2,2,3,  2,2,  2,3,  2,2,  1,2,  1,1,1,1
]);

-- SECRETARIA (risco baixo)
SELECT insert_survey('Natália Borges', ARRAY[
  1,2,1,  2,  2,2,2,  1,  4,4,4,4,  4,5,4,  4,4,  5,5,5,  5,4,5,  1,1,1,  5,4,4,  4,5,4,  5,5,4,  4,5,5,4,  1,1,5,  5,4,1,  5,4,4,  5,4,  5,4,5,  5,4,  5,4,5,4,  1,  5,  1,1,1,  1,1,  1,1,  1,1,  1,1,  1,1,1,1
]);
SELECT insert_survey('Otávio Pinto', ARRAY[
  2,1,2,  2,  3,2,2,  2,  4,3,4,3,  4,4,4,  4,4,  4,4,4,  4,4,4,  2,2,1,  4,4,4,  4,4,3,  4,4,4,  4,4,4,4,  2,1,4,  4,4,1,  4,4,4,  4,4,  4,4,4,  4,4,  4,4,4,4,  2,  4,  2,1,2,  1,2,  1,2,  1,2,  1,1,  1,1,1,1
]);
SELECT insert_survey('Priscila Luz', ARRAY[
  1,1,1,  2,  2,2,1,  1,  5,4,5,4,  5,5,5,  5,5,  5,5,5,  5,5,5,  1,1,1,  5,5,5,  5,5,5,  5,5,5,  5,5,5,5,  1,1,5,  5,5,1,  5,5,5,  5,5,  5,5,5,  5,5,  5,5,5,5,  1,  5,  1,1,1,  1,1,  1,1,  1,1,  1,1,  1,1,1,1
]);

-- SERVIÇOS GERAIS (risco médio, insegurança alta)
SELECT insert_survey('Renato Melo', ARRAY[
  3,3,3,  3,  2,2,2,  2,  2,1,2,2,  2,2,2,  2,2,  3,3,3,  2,3,2,  3,3,3,  3,2,2,  2,2,2,  3,3,2,  2,2,2,2,  3,3,2,  2,2,3,  2,2,2,  2,2,  2,2,2,  2,2,  2,2,2,2,  5,  2,  3,3,3,  3,3,  3,3,  2,3,  3,3,  2,1,1,1
]);
SELECT insert_survey('Simone Azevedo', ARRAY[
  3,4,3,  3,  3,2,2,  3,  2,2,1,2,  3,2,2,  3,2,  3,3,3,  3,2,2,  3,3,4,  2,3,2,  2,2,3,  3,2,2,  2,3,2,3,  3,4,2,  3,2,4,  2,3,2,  3,2,  2,3,2,  2,2,  2,3,2,3,  5,  2,  3,4,3,  3,3,  3,3,  3,3,  3,2,  2,2,1,1
]);
SELECT insert_survey('Tatiana Coelho', ARRAY[
  2,3,3,  3,  2,2,3,  2,  2,2,2,1,  3,3,2,  2,3,  3,3,3,  3,2,3,  3,3,3,  3,2,3,  2,3,2,  3,3,3,  3,2,3,2,  3,3,3,  3,2,3,  3,3,2,  3,3,  3,2,3,  3,2,  3,2,3,2,  4,  3,  3,3,3,  3,2,  3,3,  3,2,  2,3,  1,1,1,1
]);

-- ============================================
-- 5. Limpar função auxiliar
-- ============================================
DROP FUNCTION IF EXISTS insert_survey;
