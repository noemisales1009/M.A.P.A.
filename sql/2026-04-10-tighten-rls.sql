-- ============================================================
-- M.A.P.A. — Aperto da RLS (2026-04-10)
--
-- A migração inicial criou as policies de SELECT em respondents
-- e responses como "qualquer autenticado lê tudo", o que é um
-- vazamento entre empresas. Este script substitui por policies
-- que só liberam leitura se a linha pertencer à empresa do
-- usuário logado (ou se o usuário for admin).
--
-- O INSERT anônimo continua funcionando (policies separadas,
-- não são tocadas aqui).
--
-- Executar no SQL Editor do Supabase.
-- ============================================================

-- ------------------------------------------------------------
-- 1. DROP das policies frouxas existentes
-- ------------------------------------------------------------
DROP POLICY IF EXISTS "respondents_auth_read" ON respondents;
DROP POLICY IF EXISTS "responses_auth_read"   ON responses;

-- ------------------------------------------------------------
-- 2. CREATE das policies apertadas
-- ------------------------------------------------------------

-- Respondents: admin vê tudo, gestor só vê respondents dos
-- departamentos da sua empresa
CREATE POLICY "respondents_read_by_empresa" ON respondents
  FOR SELECT USING (
    -- Admin (role = 'admin'): acesso total
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
        AND profiles.role = 'admin'
    )
    OR
    -- Gestor: só os respondents dos setores da sua empresa
    department_id IN (
      SELECT d.id
      FROM departments d
      WHERE d.empresa_id = (
        SELECT empresa_id FROM profiles WHERE profiles.id = auth.uid()
      )
    )
  );

-- Responses: admin vê tudo, gestor só vê responses de respondents
-- dos departamentos da sua empresa (2 níveis de JOIN via respondents)
CREATE POLICY "responses_read_by_empresa" ON responses
  FOR SELECT USING (
    -- Admin: acesso total
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
        AND profiles.role = 'admin'
    )
    OR
    -- Gestor: só os responses cujos respondents pertencem à sua empresa
    respondent_id IN (
      SELECT r.id
      FROM respondents r
      JOIN departments d ON d.id = r.department_id
      WHERE d.empresa_id = (
        SELECT empresa_id FROM profiles WHERE profiles.id = auth.uid()
      )
    )
  );

-- ------------------------------------------------------------
-- 3. Queries de verificação (rodar uma por vez)
-- ------------------------------------------------------------

-- 3.1) Conferir que as policies novas estão no lugar
-- SELECT tablename, policyname, cmd, permissive
-- FROM pg_policies
-- WHERE tablename IN ('respondents','responses')
-- ORDER BY tablename, policyname;

-- 3.2) Testar como gestor (substitua <gestor-uuid> pelo id do profile gestor)
--      Deve retornar só os respondents da empresa dele
-- SET LOCAL role = authenticated;
-- SET LOCAL request.jwt.claims = '{"sub":"<gestor-uuid>","role":"authenticated"}';
-- SELECT id, department_id FROM respondents;
-- RESET role;
