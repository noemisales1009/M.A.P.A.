-- =============================================
-- M.A.P.A. — Supabase Database Setup
-- Execute no SQL Editor do Supabase Dashboard
-- =============================================

-- 1. TABELAS

CREATE TABLE IF NOT EXISTS empresas (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nome TEXT NOT NULL,
  cnpj TEXT UNIQUE NOT NULL,
  logo_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('admin', 'gestor')) DEFAULT 'gestor',
  empresa_id BIGINT REFERENCES empresas(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS setores (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  empresa_id BIGINT NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS respostas_brutas (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  empresa_id BIGINT REFERENCES empresas(id) ON DELETE CASCADE,
  setor_id BIGINT REFERENCES setores(id) ON DELETE CASCADE,
  respostas_json JSONB NOT NULL,
  data_criacao TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS escalas_calculadas (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  empresa_id BIGINT REFERENCES empresas(id) ON DELETE CASCADE,
  setor_id BIGINT REFERENCES setores(id) ON DELETE CASCADE,
  dimensao TEXT NOT NULL,
  score_medio REAL DEFAULT 0,
  nivel_risco TEXT CHECK (nivel_risco IN ('Verde', 'Amarelo', 'Vermelho')),
  total_respostas INTEGER DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(setor_id, dimensao)
);

-- 2. ROW LEVEL SECURITY (RLS)

ALTER TABLE empresas ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE setores ENABLE ROW LEVEL SECURITY;
ALTER TABLE respostas_brutas ENABLE ROW LEVEL SECURITY;
ALTER TABLE escalas_calculadas ENABLE ROW LEVEL SECURITY;

-- Admins can see everything
CREATE POLICY "Admins full access empresas" ON empresas
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
  );

-- Gestores can see their own company
CREATE POLICY "Gestores view own empresa" ON empresas
  FOR SELECT USING (
    id IN (SELECT empresa_id FROM profiles WHERE profiles.id = auth.uid())
  );

-- Profiles: users can see their own profile
CREATE POLICY "Users view own profile" ON profiles
  FOR SELECT USING (id = auth.uid());

-- Admins can see all profiles
CREATE POLICY "Admins full access profiles" ON profiles
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
  );

-- Setores: admins full access, gestores see own company
CREATE POLICY "Admins full access setores" ON setores
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
  );

CREATE POLICY "Gestores view own setores" ON setores
  FOR SELECT USING (
    empresa_id IN (SELECT empresa_id FROM profiles WHERE profiles.id = auth.uid())
  );

-- Respostas: anyone can insert (anonymous survey), authenticated can read
CREATE POLICY "Anyone can submit survey" ON respostas_brutas
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Authenticated can read respostas" ON respostas_brutas
  FOR SELECT USING (auth.role() = 'authenticated');

-- Escalas: authenticated can read, system can write
CREATE POLICY "Authenticated can read escalas" ON escalas_calculadas
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated can write escalas" ON escalas_calculadas
  FOR ALL USING (auth.role() = 'authenticated');

-- Allow anonymous inserts for survey
ALTER TABLE respostas_brutas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anon can insert respostas" ON respostas_brutas
  FOR INSERT TO anon WITH CHECK (true);

-- 3. SEED DATA

INSERT INTO empresas (nome, cnpj) VALUES ('LM Consultoria', '00.000.000/0001-00')
ON CONFLICT (cnpj) DO NOTHING;

INSERT INTO setores (empresa_id, nome)
SELECT e.id, s.nome
FROM empresas e, (VALUES ('Recursos Humanos'), ('Financeiro'), ('Tecnologia'), ('Operações')) AS s(nome)
WHERE e.cnpj = '00.000.000/0001-00'
ON CONFLICT DO NOTHING;

-- 4. FUNCTION: auto-create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, role, empresa_id)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'role', 'gestor'),
    (NEW.raw_user_meta_data->>'empresa_id')::BIGINT
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger: auto-create profile when a new user signs up
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
