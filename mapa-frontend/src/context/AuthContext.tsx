import { createContext, useContext, useState, useEffect, type ReactNode } from 'react';
import { supabase } from '../lib/supabase';
import type { Session } from '@supabase/supabase-js';

interface Profile {
  id: string;
  email: string;
  role: 'admin' | 'gestor';
  empresa_id: string | null;
}

interface AuthContextValue {
  user: Profile | null;
  session: Session | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<Profile | null>(null);
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      console.log('getSession result:', session?.user?.email ?? 'no session');
      setSession(session);
      if (session?.user) {
        const profile: Profile = {
          id: session.user.id,
          email: session.user.email || '',
          role: (session.user.user_metadata?.role as 'admin' | 'gestor') || 'admin',
          empresa_id: session.user.user_metadata?.empresa_id || null,
        };
        console.log('Setting user from session:', profile);
        setUser(profile);
      }
      setLoading(false);
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (_event, session) => {
        console.log('onAuthStateChange:', _event, session?.user?.email);
        setSession(session);
        if (session?.user) {
          const profile: Profile = {
            id: session.user.id,
            email: session.user.email || '',
            role: (session.user.user_metadata?.role as 'admin' | 'gestor') || 'admin',
            empresa_id: session.user.user_metadata?.empresa_id || null,
          };
          console.log('Setting user from auth change:', profile);
          setUser(profile);
        } else {
          setUser(null);
        }
        setLoading(false);
      }
    );

    return () => subscription.unsubscribe();
  }, []);

  const login = async (email: string, password: string) => {
    console.log('Attempting login for:', email);
    const { data, error } = await supabase.auth.signInWithPassword({ email, password });
    console.log('Login result:', { data: data?.user?.email, error: error?.message });
    if (error) throw error;
  };

  const logout = async () => {
    await supabase.auth.signOut();
    setUser(null);
    setSession(null);
  };

  return (
    <AuthContext.Provider value={{ user, session, loading, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}
