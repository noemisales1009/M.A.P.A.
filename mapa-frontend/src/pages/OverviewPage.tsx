import { useEffect, useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { Sidebar } from '../components/Sidebar';
import { supabase } from '../lib/supabase';

interface ResumoSetor {
  grupo_homogeneo: string;
  qtd_funcionarios: number;
  total_categorias: number;
  qtd_baixo: number;
  qtd_toleravel: number;
  qtd_moderado: number;
  qtd_significativo: number;
  qtd_intoleravel: number;
  risco_global: string;
}

interface TopRisco {
  department_name: string;
  category_name: string;
  score_medio: number;
  semaforo_cor: string;
}

const RISK_COLORS: Record<string, { bg: string; text: string; border: string; label: string }> = {
  Intolerável:   { bg: 'bg-red-50', text: 'text-red-700', border: 'border-red-200', label: 'Intolerável' },
  Significativo: { bg: 'bg-orange-50', text: 'text-orange-700', border: 'border-orange-200', label: 'Significativo' },
  Moderado:      { bg: 'bg-amber-50', text: 'text-amber-700', border: 'border-amber-200', label: 'Moderado' },
  Tolerável:     { bg: 'bg-yellow-50', text: 'text-yellow-700', border: 'border-yellow-200', label: 'Tolerável' },
  Baixo:         { bg: 'bg-green-50', text: 'text-green-700', border: 'border-green-200', label: 'Baixo' },
};

const RISK_HEX: Record<string, string> = {
  Intolerável: '#991b1b', Significativo: '#ef4444', Moderado: '#f97316', Tolerável: '#eab308', Baixo: '#22c55e',
};

export function OverviewPage() {
  const { user } = useAuth();
  const [resumo, setResumo] = useState<ResumoSetor[]>([]);
  const [topRiscos, setTopRiscos] = useState<TopRisco[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function load() {
      const [resResumo, resTop] = await Promise.all([
        supabase.from('vw_resumo_risco_departamento').select('*'),
        supabase.from('vw_media_por_categoria_setor').select('department_name, category_name, score_medio, semaforo_cor')
          .eq('semaforo_cor', 'Red').order('score_medio', { ascending: false }).limit(5),
      ]);
      if (resResumo.data) setResumo(resResumo.data);
      if (resTop.data) setTopRiscos(resTop.data);
      setLoading(false);
    }
    load();
  }, []);

  const totalSetores = resumo.length;
  const totalFuncionarios = resumo.reduce((a, r) => a + r.qtd_funcionarios, 0);
  const setoresCriticos = resumo.filter(r => r.risco_global === 'Intolerável').length;
  const alertas = resumo.reduce((a, r) => a + r.qtd_intoleravel + r.qtd_significativo, 0);

  // Score médio geral (baseado na distribuição de risco)
  const totalCats = resumo.reduce((a, r) => a + r.total_categorias, 0);
  const weightedScore = resumo.reduce((a, r) => {
    return a + r.qtd_intoleravel * 100 + r.qtd_significativo * 80 + r.qtd_moderado * 60 + r.qtd_toleravel * 40 + r.qtd_baixo * 20;
  }, 0);
  const riskIndex = totalCats > 0 ? Math.round(weightedScore / totalCats) : 0;
  const riskLabel = riskIndex > 66 ? 'Risco Alto' : riskIndex > 33 ? 'Risco Moderado' : 'Risco Baixo';
  const riskColor = riskIndex > 66 ? '#ef4444' : riskIndex > 33 ? '#eab308' : '#22c55e';

  return (
    <div className="flex h-screen overflow-hidden" style={{ backgroundColor: '#F8FAFA' }}>
      <Sidebar />

      <main className="flex-1 overflow-y-auto">
        <header className="sticky top-0 z-10 h-16 bg-white/80 backdrop-blur-md border-b border-slate-200 px-8 flex items-center justify-between">
          <div>
            <h2 className="text-xl font-bold text-slate-900">Visão Geral do Sistema</h2>
            <p className="text-xs text-slate-500">Monitoramento Baseado no Protocolo COPSOQ II</p>
          </div>
        </header>

        {loading ? (
          <div className="flex items-center justify-center h-64">
            <div className="w-8 h-8 border-4 border-slate-200 rounded-full animate-spin" style={{ borderTopColor: '#009B9B' }}></div>
          </div>
        ) : (
          <div className="p-8 space-y-8">
            {/* Summary Cards */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              {/* Risk Index */}
              <div className="bg-white p-6 rounded-2xl shadow-sm border border-slate-200">
                <div className="flex justify-between items-start mb-4">
                  <span className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Índice Geral de Risco</span>
                  <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ backgroundColor: riskColor + '15' }}>
                    <span className="material-symbols-rounded" style={{ color: riskColor }}>speed</span>
                  </div>
                </div>
                <h3 className="text-3xl font-black text-slate-900">{riskIndex}%</h3>
                <div className="mt-3 h-2 bg-slate-100 rounded-full overflow-hidden">
                  <div className="h-full rounded-full" style={{ width: `${riskIndex}%`, backgroundColor: riskColor }}></div>
                </div>
                <p className="mt-2 text-xs text-slate-500">Status: <span className="font-bold" style={{ color: riskColor }}>{riskLabel}</span></p>
              </div>

              {/* Total Setores */}
              <div className="bg-white p-6 rounded-2xl shadow-sm border border-slate-200">
                <div className="flex justify-between items-start mb-4">
                  <span className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Setores Mapeados</span>
                  <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ backgroundColor: '#009B9B15' }}>
                    <span className="material-symbols-rounded" style={{ color: '#009B9B' }}>domain</span>
                  </div>
                </div>
                <h3 className="text-3xl font-black text-slate-900">{totalSetores}</h3>
                <p className="mt-4 text-xs text-slate-500"><span className="font-bold text-slate-700">{totalFuncionarios}</span> colaboradores avaliados</p>
              </div>

              {/* Setores Críticos */}
              <div className="bg-white p-6 rounded-2xl shadow-sm border border-slate-200 border-l-4 border-l-red-500">
                <div className="flex justify-between items-start mb-4">
                  <span className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Setores Críticos</span>
                  <div className="w-10 h-10 rounded-xl bg-red-50 flex items-center justify-center">
                    <span className="material-symbols-rounded text-red-500">warning</span>
                  </div>
                </div>
                <h3 className="text-3xl font-black text-red-600">{setoresCriticos}</h3>
                <p className="mt-4 text-xs text-slate-500">Classificação <span className="font-bold text-red-500">Intolerável</span></p>
              </div>

              {/* Alertas */}
              <div className="bg-white p-6 rounded-2xl shadow-sm border border-slate-200">
                <div className="flex justify-between items-start mb-4">
                  <span className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Alertas Ativos</span>
                  <div className="w-10 h-10 rounded-xl bg-red-50 flex items-center justify-center">
                    <span className="material-symbols-rounded text-red-500">notification_important</span>
                  </div>
                </div>
                <h3 className="text-3xl font-black text-slate-900">{alertas}</h3>
                <p className="mt-4 text-xs text-slate-500">Categorias em risco significativo+</p>
              </div>
            </div>

            {/* Setores + Top Riscos */}
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
              {/* Tabela de Setores */}
              <div className="lg:col-span-2 bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
                <div className="px-8 py-6 border-b border-slate-100">
                  <h4 className="text-lg font-bold text-slate-900">Resumo por Setor</h4>
                </div>
                <table className="w-full text-left">
                  <thead className="bg-slate-50 text-[10px] text-slate-500 uppercase font-bold tracking-widest">
                    <tr>
                      <th className="px-8 py-4">Setor</th>
                      <th className="px-8 py-4">Func.</th>
                      <th className="px-8 py-4">Risco Global</th>
                      <th className="px-8 py-4">Intol.</th>
                      <th className="px-8 py-4">Signif.</th>
                      <th className="px-8 py-4">Moder.</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {resumo
                      .sort((a, b) => b.qtd_intoleravel - a.qtd_intoleravel)
                      .map((r) => {
                        const style = RISK_COLORS[r.risco_global] || RISK_COLORS.Baixo;
                        return (
                          <tr key={r.grupo_homogeneo} className="hover:bg-slate-50 transition-colors">
                            <td className="px-8 py-4 text-sm font-bold text-slate-800">{r.grupo_homogeneo}</td>
                            <td className="px-8 py-4 text-sm text-slate-600">{r.qtd_funcionarios}</td>
                            <td className="px-8 py-4">
                              <span className={`px-2.5 py-1 text-[10px] font-bold uppercase rounded-md border ${style.bg} ${style.text} ${style.border}`}>
                                {style.label}
                              </span>
                            </td>
                            <td className="px-8 py-4 text-sm font-bold text-red-600">{r.qtd_intoleravel || '-'}</td>
                            <td className="px-8 py-4 text-sm font-bold text-orange-500">{r.qtd_significativo || '-'}</td>
                            <td className="px-8 py-4 text-sm font-bold text-amber-500">{r.qtd_moderado || '-'}</td>
                          </tr>
                        );
                      })}
                  </tbody>
                </table>
              </div>

              {/* Top Riscos */}
              <div className="bg-white p-8 rounded-2xl shadow-sm border border-slate-200">
                <h4 className="text-lg font-bold mb-6 text-slate-900">Top 5 Fatores de Risco</h4>
                <div className="flex flex-col gap-4">
                  {topRiscos.map((r, i) => (
                    <div key={i} className="p-4 rounded-xl bg-red-50 border border-red-100">
                      <div className="flex justify-between items-center mb-2">
                        <span className="text-sm font-bold text-slate-800">{r.category_name}</span>
                        <span className="text-[10px] font-black text-white bg-red-500 px-2 py-0.5 rounded">{Math.round(r.score_medio)}%</span>
                      </div>
                      <div className="h-2 w-full bg-red-100 rounded-full overflow-hidden">
                        <div className="h-full bg-red-500 rounded-full" style={{ width: `${r.score_medio}%` }}></div>
                      </div>
                      <p className="text-[11px] text-slate-500 mt-1">{r.department_name}</p>
                    </div>
                  ))}
                  {topRiscos.length === 0 && (
                    <p className="text-sm text-slate-400 text-center py-8">Nenhum fator em risco alto</p>
                  )}
                </div>
              </div>
            </div>

            {/* Alertas por Setor (Intoleráveis) */}
            <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
              <div className="px-8 py-6 flex justify-between items-center border-b border-slate-100">
                <h4 className="text-lg font-bold text-slate-900">Setores com Risco Intolerável</h4>
                <span className="text-xs font-bold text-red-500">{setoresCriticos} setores</span>
              </div>
              <div className="divide-y divide-slate-100">
                {resumo
                  .filter(r => r.risco_global === 'Intolerável')
                  .sort((a, b) => b.qtd_intoleravel - a.qtd_intoleravel)
                  .map((r) => (
                    <div key={r.grupo_homogeneo} className="px-8 py-4 flex items-center justify-between hover:bg-slate-50 transition-colors">
                      <div className="flex items-center gap-4">
                        <div className="w-10 h-10 rounded-xl bg-red-100 flex items-center justify-center">
                          <span className="material-symbols-rounded text-red-600 text-lg">report</span>
                        </div>
                        <div>
                          <p className="text-sm font-bold text-slate-800">{r.grupo_homogeneo}</p>
                          <p className="text-xs text-slate-500">{r.qtd_funcionarios} colaboradores • {r.qtd_intoleravel} categorias intoleráveis</p>
                        </div>
                      </div>
                      <span className="px-3 py-1 bg-red-50 text-red-700 text-[10px] font-black uppercase rounded-md border border-red-200">
                        Medidas Urgentes
                      </span>
                    </div>
                  ))}
              </div>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}
