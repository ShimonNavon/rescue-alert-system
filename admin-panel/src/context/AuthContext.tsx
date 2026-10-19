import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';

export interface AuthUser {
  id: number;
  username: string;
  email: string;
  name: string;
  role: string | null;
  is_staff: boolean;
}

interface AuthContextType {
  user: AuthUser | null;
  loading: boolean;
  login: (identifier: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType>({
  user: null,
  loading: true,
  login: async () => {},
  logout: async () => {},
});

const API_BASE = import.meta.env.VITE_API_BASE_URL || '/api/';

function getCookie(name: string): string {
  const prefix = `${name}=`;
  const match = document.cookie.split('; ').find((item) => item.startsWith(prefix));
  return match ? decodeURIComponent(match.slice(prefix.length)) : '';
}

async function ensureCsrfToken(): Promise<string> {
  const existing = getCookie('csrftoken');
  if (existing) return existing;

  // The GET also sets the CSRF cookie. This is needed when the session page
  // was loaded before the cookie existed or after it expired.
  await fetch(`${API_BASE}auth/session/`, { credentials: 'include' });
  return getCookie('csrftoken');
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;

    fetch(`${API_BASE}auth/session/`, { credentials: 'include' })
      .then((response) => response.json())
      .then((data) => {
        if (!cancelled) setUser(data.authenticated ? data.user : null);
      })
      .catch(() => {
        if (!cancelled) setUser(null);
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });

    return () => {
      cancelled = true;
    };
  }, []);

  const login = async (identifier: string, password: string) => {
    const csrfToken = await ensureCsrfToken();
    const response = await fetch(`${API_BASE}auth/session/login/`, {
      method: 'POST',
      credentials: 'include',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRFToken': csrfToken,
      },
      body: JSON.stringify({ username: identifier.trim(), password }),
    });

    const data = await response.json().catch(() => ({}));
    if (!response.ok) {
      const detail =
        data.detail ||
        data.non_field_errors?.[0] ||
        data.username?.[0] ||
        'Sign in failed. Check your email and password.';
      throw new Error(detail);
    }

    setUser(data.user);
  };

  const logout = async () => {
    const csrfToken = getCookie('csrftoken');
    try {
      await fetch(`${API_BASE}auth/session/logout/`, {
        method: 'POST',
        credentials: 'include',
        headers: csrfToken ? { 'X-CSRFToken': csrfToken } : undefined,
      });
    } finally {
      setUser(null);
    }
  };

  return (
    <AuthContext.Provider value={{ user, loading, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);
