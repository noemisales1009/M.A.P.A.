import { useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import {
  LayoutDashboard,
  AlertTriangle,
  Building2,
  FileBarChart,
  Wallet,
  Settings,
  ShieldCheck,
  FileText,
  LogOut,
} from 'lucide-react';

export function Sidebar() {
  const navigate = useNavigate();
  const location = useLocation();
  const { user, logout } = useAuth();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const menuItems = [
    { label: 'Dashboard', icon: LayoutDashboard, path: '/overview' },
    { label: 'Priorização', icon: AlertTriangle, path: '/dashboard' },
    { label: 'Setores', icon: Building2, path: '/setores' },
    { label: 'Relatórios', icon: FileBarChart, path: '/reports' },
    { label: 'Financeiro', icon: Wallet, path: '/financeiro' },
    { label: 'Configurações', icon: Settings, path: '/settings' },
    ...(user?.role === 'admin' ? [{ label: 'Super Admin', icon: ShieldCheck, path: '/super-admin' }] : []),
  ];

  const isActive = (path: string) => location.pathname === path;

  const displayName = user?.email?.split('@')[0] || 'Usuário';
  const roleLabel = user?.role === 'admin' ? 'Administrador' : 'Gestor';

  return (
    <aside className="w-72 flex flex-col sticky top-0 h-screen" style={{ backgroundColor: '#2D5A5A' }}>
      {/* Logo */}
      <div className="p-6 flex items-center gap-3 border-b border-white/10">
        <img src="/logo-mapa.png" alt="M.A.P.A." className="w-11 h-11 rounded-xl object-cover" />
        <div>
          <h1 className="font-extrabold text-lg leading-tight text-white tracking-tight">M.A.P.A.</h1>
          <p className="text-[10px] text-white/50 uppercase tracking-widest font-bold">Saúde Mental Ocupacional</p>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 px-3 py-6 space-y-1 overflow-y-auto">
        {menuItems.map((item) => {
          const Icon = item.icon;
          return (
            <a
              key={item.path}
              onClick={() => navigate(item.path)}
              className={`flex items-center gap-3 px-4 py-3 rounded-xl transition-all cursor-pointer ${
                isActive(item.path)
                  ? 'text-white shadow-lg'
                  : 'text-white/60 hover:text-white hover:bg-white/10'
              }`}
              style={isActive(item.path) ? { backgroundColor: '#009B9B' } : {}}
            >
              <Icon size={20} strokeWidth={isActive(item.path) ? 2.5 : 2} />
              <span className="font-semibold text-sm">{item.label}</span>
            </a>
          );
        })}
      </nav>

      {/* Bottom Section */}
      <div className="p-4 border-t border-white/10 space-y-3">
        {/* Generate Report Button */}
        <button
          onClick={() => navigate('/reports')}
          className="w-full px-4 py-3 rounded-xl text-white font-bold text-sm flex items-center justify-center gap-2 shadow-lg hover:shadow-xl transition-all"
          style={{ backgroundColor: '#009B9B' }}
        >
          <FileText size={18} />
          Gerar Relatório PGR
        </button>

        {/* User Card */}
        <div className="flex items-center gap-3 p-3 rounded-xl bg-white/10">
          <div className="w-10 h-10 rounded-full flex items-center justify-center text-sm font-bold text-white" style={{ backgroundColor: '#009B9B' }}>
            {displayName.charAt(0).toUpperCase()}
          </div>
          <div className="flex-1 overflow-hidden">
            <p className="text-sm font-bold text-white truncate">{displayName}</p>
            <p className="text-[11px] text-white/50 truncate">{roleLabel}</p>
          </div>
        </div>

        {/* Logout Button */}
        <button
          onClick={handleLogout}
          className="w-full px-4 py-2.5 rounded-xl border border-white/20 text-white/60 font-semibold text-sm hover:text-red-300 hover:border-red-400/30 hover:bg-red-500/10 transition-all flex items-center justify-center gap-2"
        >
          <LogOut size={18} />
          Sair
        </button>
      </div>
    </aside>
  );
}
