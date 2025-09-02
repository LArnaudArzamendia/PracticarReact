const API_BASE  = import.meta.env.VITE_API_BASE_URL  || '/api';
const AUTH_BASE = import.meta.env.VITE_AUTH_BASE_URL || '';   

export async function signIn({ email, password }) {
  const res = await fetch(`${AUTH_BASE}/users/sign_in`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    credentials: 'include',
    body: JSON.stringify({ user: { email, password } }),
  });

  let data = null;
  try { data = await res.json(); } catch {}

  if (!res.ok) {
    const message = (data && (data.error || data.message)) || 'Login error';
    throw new Error(message);
  }
  return data || { status: 'ok' };
}

export async function signOut() {
  const res = await fetch(`${AUTH_BASE}/users/sign_out`, {
    method: 'DELETE',
    credentials: 'include',
  });
  if (!res.ok) throw new Error('No se pudo cerrar sesión');
  return { status: 'logged_out' };
}