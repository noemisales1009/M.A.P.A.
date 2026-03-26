import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Eye, EyeOff, Lock, Mail } from 'lucide-react';
import { useAuth } from '../context/AuthContext';

export function LoginPage() {
  const { login, user } = useAuth();
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [senha, setSenha] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  // Redirect when user becomes available (after login or already logged in)
  useEffect(() => {
    if (user) {
      navigate('/overview', { replace: true });
    }
  }, [user, navigate]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      if (!email || !senha) {
        throw new Error('Preencha todos os campos.');
      }
      await login(email, senha);
      // Navigation will happen via useEffect when user state updates
    } catch (err: any) {
      setError(err.message === 'Invalid login credentials'
        ? 'E-mail ou senha incorretos.'
        : err.message ?? 'Erro ao conectar ao servidor.');
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center font-display">
      <div className="flex w-full min-h-screen">
        {/* Left Side - Graphic (Hidden on mobile) */}
        <div className="hidden lg:flex lg:w-1/2 relative overflow-hidden" style={{ background: 'linear-gradient(to bottom, #e6f5f5, #f0fafa, #e6f5f5)' }}>
          <div className="absolute inset-0 opacity-30">
            <div className="absolute w-96 h-96 rounded-full -top-24 -left-24 blur-3xl" style={{ backgroundColor: '#009B9B' }}></div>
            <div className="absolute w-96 h-96 rounded-full -bottom-32 -right-32 blur-3xl" style={{ backgroundColor: '#2D5A5A' }}></div>
          </div>
          
          <div className="relative z-10 flex flex-col items-center justify-center w-full p-12 text-center h-full">
            <div className="relative z-20 space-y-8 flex flex-col items-center justify-center h-full max-w-lg mx-auto">
              <img
                src="/logo-mapa.png"
                alt="Ciclo de Inteligência Psicossocial LM"
                className="w-72 h-72 rounded-full shadow-2xl border-4 border-white object-cover"
              />
              <div className="space-y-3">
                <h1 className="text-5xl font-black leading-tight" style={{ color: '#2D5A5A' }}>M.A.P.A.</h1>
                <p className="text-lg font-semibold" style={{ color: '#009B9B' }}>Bem-estar e Saúde Mental Ocupacional</p>
                <p className="max-w-sm mx-auto text-sm leading-relaxed" style={{ color: '#404040' }}>Uma iniciativa LM Consultoria para transformar o ambiente corporativo através do cuidado.</p>
              </div>
            </div>
          </div>
        </div>

        {/* Right Side - Login Form */}
        <div className="w-full lg:w-1/2 flex items-center justify-center p-6 sm:p-12 md:p-20 bg-white">
          <div className="w-full max-w-lg space-y-8">
            <header className="flex flex-col items-center space-y-3">
              <div className="flex items-center gap-2">
                <img src="/logo-mapa.png" alt="M.A.P.A." className="w-10 h-10 rounded-lg object-cover" />
                <h2 className="text-2xl font-black tracking-tight text-primary">M.A.P.A.</h2>
              </div>
              
              <div className="text-center">
                <h3 className="text-3xl font-bold text-slate-900">Acessar sua conta</h3>
                <p className="text-slate-500 mt-2 text-sm">Bem-vindo à plataforma de saúde LM Consultoria</p>
              </div>
            </header>

            <form onSubmit={handleSubmit} className="space-y-5">
              {error && (
                <div className="bg-red-50 text-red-600 p-4 rounded-xl text-sm font-medium border border-red-200 flex items-start gap-3">
                  <span className="material-symbols-rounded shrink-0">error</span>
                  <p>{error}</p>
                </div>
              )}

              <div className="space-y-2">
                <label className="block text-sm font-semibold text-slate-700 ml-1">
                  E-mail
                </label>
                <div className="relative group">
                  <Mail className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-primary transition-colors" size={20} />
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    required
                    className="w-full h-12 pl-12 pr-4 bg-slate-50 border border-slate-200 rounded-lg focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all outline-none text-slate-900 placeholder:text-slate-400"
                    placeholder="nome@exemplo.com"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <div className="flex justify-between items-center px-1">
                  <label className="text-sm font-semibold text-slate-700">
                    Senha
                  </label>
                  <a href="#" className="text-xs font-semibold hover:underline transition-all" style={{ color: '#009B9B' }}>
                    Esqueci minha senha
                  </a>
                </div>
                <div className="relative group">
                  <Lock className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-primary transition-colors" size={20} />
                  <input
                    type={showPassword ? 'text' : 'password'}
                    value={senha}
                    onChange={(e) => setSenha(e.target.value)}
                    required
                    className="w-full h-12 pl-12 pr-12 bg-slate-50 border border-slate-200 rounded-lg focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all outline-none text-slate-900 placeholder:text-slate-400"
                    placeholder="••••••••"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 transition-colors"
                  >
                    {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                  </button>
                </div>
              </div>

              <button
                type="submit"
                disabled={loading}
                style={{ backgroundColor: '#009B9B', cursor: 'pointer' }}
                className="w-full h-12 text-white rounded-full font-bold text-base transform active:scale-95 transition-all disabled:opacity-70 flex justify-center items-center hover:opacity-90"
              >
                {loading ? (
                  <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
                ) : (
                  'Entrar no Sistema'
                )}
              </button>
            </form>

            <footer className="space-y-4 text-center pt-2">
              <div className="flex items-center justify-center gap-2 p-3 bg-slate-50 rounded-lg border border-slate-200">
                <span className="material-symbols-rounded text-slate-400 text-sm">info</span>
                <p className="text-xs text-slate-600 font-medium">Acesso restrito para administradores e gestores cadastrados.</p>
              </div>
              
              <div className="flex justify-center">
                <button className="flex items-center gap-2 text-xs text-slate-500 hover:text-blue-600 transition-colors">
                  <span className="material-symbols-rounded text-sm">help</span>
                  Suporte
                </button>
              </div>
            </footer>
          </div>
        </div>
      </div>
    </div>
  );
}
