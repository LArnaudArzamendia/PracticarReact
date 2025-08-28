import { useState } from 'react';
import { signIn, signOut } from '../lib/api';

export default function LoginForm() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const [submitting, setSubmitting] = useState(false);
  const [msg, setMsg] = useState(null);
  const [error, setError] = useState(null);

  async function handleSubmit(e) {
    e.preventDefault();
    setSubmitting(true);
    setMsg(null);
    setError(null);

    try {
      // Evita el caso “cookie prevalece”: limpia sesión antes de reintentar login
      await signOut().catch(() => {}); // ignoramos error si no había sesión
      await signIn({ email, password });
      setMsg('login exitoso');
    } catch (err) {
      setMsg('login error');
      setError(err.message || 'Error de autenticación');
    } finally {
      setSubmitting(false);
    }
  }

  async function handleSignOut() {
    setSubmitting(true);
    setMsg(null);
    setError(null);
    try {
      await signOut();
      setMsg('Sesión cerrada');
    } catch (err) {
      setError(err.message || 'No se pudo cerrar sesión');
    } finally {
      setSubmitting(false);
    }
  }

  const disabled = submitting || !email.trim() || !password;

  return (
    <div className="login-card">
      <h2>Iniciar sesión</h2>
      <form onSubmit={handleSubmit} noValidate>
        <label>
          Email
          <input
            type="email"
            autoComplete="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            placeholder="usuario@ejemplo.com"
          />
        </label>

        <label>
          Contraseña
          <input
            type="password"
            autoComplete="current-password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
            placeholder="********"
          />
        </label>

        <div className="actions">
          <button type="submit" disabled={disabled}>
            {submitting ? 'Ingresando…' : 'Ingresar'}
          </button>
          <button type="button" onClick={handleSignOut} disabled={submitting}>
            Cerrar sesión
          </button>
        </div>
      </form>

      {msg && <p className={msg.includes('exitoso') ? 'ok' : 'warn'}>{msg}</p>}
      {error && <p className="error">{error}</p>}

      <style>{`
        .login-card { max-width: 360px; margin: 2rem auto; padding: 1.5rem; border: 1px solid #eee; border-radius: 12px; }
        form { display: grid; gap: .75rem; }
        label { display: grid; gap: .35rem; font-size: .95rem; }
        input { padding: .6rem .7rem; border: 1px solid #ccc; border-radius: 8px; }
        .actions { display: flex; gap: .5rem; margin-top: .5rem; }
        button { padding: .6rem .9rem; border: 0; border-radius: 8px; cursor: pointer; }
        button[disabled] { opacity: .6; cursor: not-allowed; }
        .ok { color: #137333; }
        .warn { color: #b06000; }
        .error { color: #b00020; }
      `}</style>
    </div>
  );
}
