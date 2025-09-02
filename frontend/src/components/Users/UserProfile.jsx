import { useEffect, useState } from "react";
import { useParams, Link as RouterLink } from "react-router-dom";
import {
  Container, Typography, Card, CardContent, Stack, Button
} from "@mui/material";
import axios from "axios";

export default function UserProfile() {
  const { id } = useParams();
  const [profile, setProfile] = useState(null);

  useEffect(() => {
    axios.get(`/api/v1/users/${id}`)
      .then(res => setProfile(res.data))
      .catch(err => console.error(err));
  }, [id]);

  if (!profile) {
    return (
      <Container>
        <Typography>Cargando...</Typography>
      </Container>
    );
  }

  const { user, public_trips = [] } = profile;

  return (
    <Container>
      <Typography variant="h4" gutterBottom>Perfil de {user.handle}</Typography>
      <Typography variant="body2" color="text.secondary">{user.email}</Typography>

      <Typography variant="h6" sx={{ mt: 3 }}>Viajes públicos</Typography>
      {public_trips.length === 0 ? (
        <Typography color="text.secondary">Sin viajes públicos.</Typography>
      ) : (
        <Stack spacing={2} sx={{ mt: 1 }}>
          {public_trips.map(t => (
            <Card key={t.id}>
              <CardContent>
                <Typography variant="subtitle1">{t.title}</Typography>
                <Typography variant="body2" color="text.secondary">
                  {t.description || "—"}
                </Typography>
                <Stack direction="row" spacing={1} sx={{ mt: 1 }}>
                  <Button component={RouterLink} to={`/trips/${t.id}/locations`} variant="outlined" size="small">
                    Ver lugares
                  </Button>
                  <Button component={RouterLink} to={`/trips/${t.id}/map`} variant="outlined" size="small">
                    Ver mapa
                  </Button>
                </Stack>
              </CardContent>
            </Card>
          ))}
        </Stack>
      )}
    </Container>
  );
}