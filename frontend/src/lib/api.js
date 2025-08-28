const API_BASE = import.meta.env.VITE_API_BASE_URL || 'http://localhost:3001';

export async function signIn({ email, password }) {
  const res = await fetch(`${API_BASE}/users/sign_in`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    credentials: 'include', // importante para cookie http-only
    body: JSON.stringify({ user: { email, password } }),
  });

  let data = null;
  try { data = await res.json(); } catch { /* empty */ }

  if (!res.ok) {
    const message = (data && (data.error || data.message)) || 'Login error';
    throw new Error(message);
  }
  return data || { status: 'ok' };
}

export async function signOut() {
  const res = await fetch(`${API_BASE}/users/sign_out`, {
    method: 'DELETE',
    credentials: 'include',
  });
  // algunas configuraciones devuelven 204/200 sin cuerpo
  if (!res.ok) throw new Error('No se pudo cerrar sesión');
  return { status: 'logged_out' };
}
