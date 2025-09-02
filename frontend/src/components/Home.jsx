import { Container, Typography, Grid, Card, CardContent, Button } from "@mui/material";
import { Link as RouterLink } from "react-router-dom";

export default function Home() {
  return (
    <Container>
      <Typography variant="h4" gutterBottom>Inicio</Typography>

      <Grid container spacing={2}>
        <Grid item xs={12} md={4}>
          <Card>
            <CardContent>
              <Typography variant="h6">Mis viajes</Typography>
              <Typography variant="body2" color="text.secondary">Lista de mis viajes y destinos.</Typography>
              <Button component={RouterLink} to="/trips" sx={{ mt: 1 }} variant="contained">Ir</Button>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} md={4}>
          <Card>
            <CardContent>
              <Typography variant="h6">Buscar usuarios</Typography>
              <Typography variant="body2" color="text.secondary">Encuentra perfiles por handle.</Typography>
              <Button component={RouterLink} to="/users/search" sx={{ mt: 1 }} variant="contained">Ir</Button>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} md={4}>
          <Card>
            <CardContent>
              <Typography variant="h6">Bienvenida</Typography>
              <Typography variant="body2" color="text.secondary">Pantalla de onboarding.</Typography>
              <Button component={RouterLink} to="/welcome" sx={{ mt: 1 }} variant="contained">Ver</Button>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Container>
  );
}