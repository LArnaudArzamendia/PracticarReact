import { Container, Typography, Button, Stack } from "@mui/material";
import { Link as RouterLink, useLocation, useNavigate } from "react-router-dom";
import LoginForm from "./LoginForm";
import { useAuth } from "../context/AuthContext";
import { useEffect } from "react";

export default function Welcome() {
  const { isAuthed } = useAuth();
  const nav = useNavigate();
  const loc = useLocation();

  useEffect(() => {
    if (isAuthed) {
      const to = loc.state?.from?.pathname || "/trips";
      nav(to, { replace: true });
    }
  }, [isAuthed, loc.state, nav]);

  return (
    <Container sx={{ textAlign: "center", py: 6 }}>
      <Typography variant="h3" gutterBottom>Bienvenido a TravelLife</Typography>
      <Typography variant="body1" color="text.secondary" sx={{ mb: 3 }}>
        Comparte tus viajes, etiqueta a tus buddies y crea tu galería multimedia.
      </Typography>

      {!isAuthed && <LoginForm />}

      <Stack direction="row" spacing={2} justifyContent="center" sx={{ mt: 3 }}>
        <Button component={RouterLink} to="/users/search" variant="contained">
          Explorar usuarios
        </Button>
        <Button component={RouterLink} to="/trips" variant="outlined">
          Ver mis viajes
        </Button>
      </Stack>
    </Container>
  );
}
