import { createContext, useContext, useEffect, useState } from "react";
import { signIn as apiSignIn, signOut as apiSignOut } from "../lib/api";

const AuthCtx = createContext(null);
export const useAuth = () => useContext(AuthCtx);

export function AuthProvider({ children }) {
  const [isAuthed, setIsAuthed] = useState(false);

  useEffect(() => {
    setIsAuthed(localStorage.getItem("isAuthed") === "1");
  }, []);

  const login = async ({ email, password }) => {
    await apiSignIn({ email, password });
    localStorage.setItem("isAuthed", "1");
    setIsAuthed(true);
  };

  const logout = async () => {
    try { await apiSignOut(); } catch {}
    localStorage.removeItem("isAuthed");
    setIsAuthed(false);
  };

  return (
    <AuthCtx.Provider value={{ isAuthed, login, logout }}>
      {children}
    </AuthCtx.Provider>
  );
}