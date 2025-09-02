import { useState } from "react";
import { TextField, Button, Stack, Alert } from "@mui/material";
import { useAuth } from "../context/AuthContext";

export default function LoginForm() {
  const { login } = useAuth();
  const [email, setEmail] = useState("tester@example.com");
  const [password, setPassword] = useState("password123");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError("");
    try {
      await login({ email, password });
    } catch (err) {
      setError(err?.message || "Login failed");
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} noValidate>
      {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}
      <Stack direction="row" spacing={2} alignItems="center">
        <TextField label="Email" value={email} onChange={(e) => setEmail(e.target.value)} size="small" />
        <TextField label="Password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} size="small" />
        <Button type="submit" variant="contained" disabled={loading}>
          {loading ? "Ingresando…" : "Ingresar"}
        </Button>
      </Stack>
    </form>
  );
}