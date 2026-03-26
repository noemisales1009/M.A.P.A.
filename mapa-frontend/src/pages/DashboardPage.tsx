import { useEffect, useState } from 'react';
import { Sidebar } from '../components/Sidebar';
import { supabase } from '../lib/supabase';

interface PgrRow {
  qtd_funcionarios: number;
  grupo_homogeneo: string;
  descricao_perigo: string;
  trabalhadores_expostos: number;
  incidencia: string;
  probabilidade: number;
  severidade: number;
  grau_risco: number;
  classificacao_risco: string;
  medidas_controle: string;
  score_medio: number;
  cor_hex: string;
}

const RISK_ORDER = ['Intolerável', 'Significativo', 'Moderado', 'Tolerável', 'Baixo'];

export function DashboardPage() {
  const [dados, setDados] = useState<PgrRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [filtroSetor, setFiltroSetor] = useState('');
  const [filtroRisco, setFiltroRisco] = useState('');

  useEffect(() => {
    async function load() {
      const { data } = await supabase.from('vw_pgr_completo').select('*');
      if (data) setDados(data);
      setLoading(false);
    }
    load();
  }, []);

  const setores = [...new Set(dados.map(d => d.grupo_homogeneo))].sort();
  const filtered = dados
    .filter(d => !filtroSetor || d.grupo_homogeneo === filtroSetor)
    .filter(d => !filtroRisco || d.classificacao_risco === filtroRisco)
    .sort((a, b) => b.grau_risco - a.grau_risco);

  const riskCounts = {
    Intolerável: filtered.filter(d => d.classificacao_risco === 'Intolerável').length,
    Significativo: filtered.filter(d => d.classificacao_risco === 'Significativo').length,
    Moderado: filtered.filter(d => d.classificacao_risco === 'Moderado').length,
    Tolerável: filtered.filter(d => d.classificacao_risco === 'Tolerável').length,
    Baixo: filtered.filter(d => d.classificacao_risco === 'Baixo').length,
  };

  return (
    <div className="flex min-h-screen" style={{ backgroundColor: '#F8FAFA' }}>
      <Sidebar />

      <main className="flex-1 flex flex-col min-w-0 overflow-hidden">
        <header className="h-16 bg-white border-b border-slate-200 px-8 flex items-center justify-between shrink-0">
          <h1 className="text-xl font-bold text-slate-900">Painel de Priorização PGR</h1>
          <div className="flex items-center gap-3">
            <select
              value={filtroSetor}
              onChange={e => setFiltroSetor(e.target.value)}
              className="px-3 py-2 text-sm border border-slate-200 rounded-lg bg-white text-slate-700"
            >
              <option value="">Todos os Setores</option>
              {setores.map(s => <option key={s} value={s}>{s}</option>)}
            </select>
            <select
              value={filtroRisco}
              onChange={e => setFiltroRisco(e.target.value)}
              className="px-3 py-2 text-sm border border-slate-200 rounded-lg bg-white text-slate-700"
            >
              <option value="">Todos os Riscos</option>
              {RISK_ORDER.map(r => <option key={r} value={r}>{r}</option>)}
            </select>
          </div>
        </header>

        <div className="flex-1 p-8 overflow-y-auto">
          {loading ? (
            <div className="flex items-center justify-center h-64">
              <div className="w-8 h-8 border-4 border-slate-200 rounded-full animate-spin" style={{ borderTopColor: '#009B9B' }}></div>
            </div>
          ) : (
            <>
              {/* Summary */}
              <div className="grid grid-cols-2 md:grid-cols-5 gap-4 mb-8">
                {RISK_ORDER.map(risk => {
                  const count = riskCounts[risk as keyof typeof riskCounts];
                  const colors: Record<string, string> = {
                    Intolerável: '#991b1b', Significativo: '#ef4444', Moderado: '#f97316', Tolerável: '#eab308', Baixo: '#22c55e'
                  };
                  return (
                    <div
                      key={risk}
                      onClick={() => setFiltroRisco(filtroRisco === risk ? '' : risk)}
                      className={`bg-white p-4 rounded-xl border-2 cursor-pointer transition-all ${filtroRisco === risk ? 'shadow-lg scale-105' : 'border-slate-200 hover:border-slate-300'}`}
                      style={filtroRisco === risk ? { borderColor: colors[risk] } : {}}
                    >
                      <p className="text-[10px] font-bold uppercase tracking-widest text-slate-400">{risk}</p>
                      <p className="text-2xl font-black mt-1" style={{ color: colors[risk] }}>{count}</p>
                    </div>
                  );
                })}
              </div>

              {/* Table */}
              <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
                <div className="px-6 py-4 border-b border-slate-100 flex items-center justify-between">
                  <h3 className="font-bold text-slate-800">
                    {filtered.length} registros {filtroSetor && `• ${filtroSetor}`} {filtroRisco && `• ${filtroRisco}`}
                  </h3>
                </div>
                <div className="overflow-x-auto">
                  <table className="w-full text-left">
                    <thead className="bg-slate-50 text-[10px] text-slate-500 uppercase font-bold tracking-widest">
                      <tr>
                        <th className="px-6 py-3">Setor</th>
                        <th className="px-6 py-3">Categoria COPSOQ</th>
                        <th className="px-6 py-3">Score</th>
                        <th className="px-6 py-3">Prob.</th>
                        <th className="px-6 py-3">Sev.</th>
                        <th className="px-6 py-3">Grau</th>
                        <th className="px-6 py-3">Classificação</th>
                        <th className="px-6 py-3">Ação</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-100">
                      {filtered.map((row, i) => (
                        <tr key={i} className="hover:bg-slate-50 transition-colors">
                          <td className="px-6 py-3 text-sm font-medium text-slate-800">{row.grupo_homogeneo}</td>
                          <td className="px-6 py-3 text-sm text-slate-600">{row.descricao_perigo}</td>
                          <td className="px-6 py-3">
                            <div className="flex items-center gap-2">
                              <div className="w-12 h-1.5 bg-slate-100 rounded-full overflow-hidden">
                                <div className="h-full rounded-full" style={{ width: `${row.score_medio}%`, backgroundColor: row.cor_hex }}></div>
                              </div>
                              <span className="text-xs font-bold" style={{ color: row.cor_hex }}>{row.score_medio}%</span>
                            </div>
                          </td>
                          <td className="px-6 py-3 text-sm font-bold text-slate-700">{row.probabilidade}</td>
                          <td className="px-6 py-3 text-sm font-bold text-slate-700">{row.severidade}</td>
                          <td className="px-6 py-3 text-sm font-black" style={{ color: row.cor_hex }}>{row.grau_risco}</td>
                          <td className="px-6 py-3">
                            <span
                              className="px-2 py-1 text-[10px] font-bold uppercase rounded-md text-white"
                              style={{ backgroundColor: row.cor_hex }}
                            >
                              {row.classificacao_risco}
                            </span>
                          </td>
                          <td className="px-6 py-3 text-xs text-slate-500 max-w-[200px] truncate" title={row.medidas_controle}>
                            {row.medidas_controle}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            </>
          )}
        </div>
      </main>
    </div>
  );
}
