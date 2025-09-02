import { useEffect, useState } from "react";
import { useParams, Link as RouterLink } from "react-router-dom";
import {
  Container, Typography, Card, CardContent, Box, List, ListItem, ListItemText, Button, Stack
} from "@mui/material";
import axios from "axios";

export default function TripMap() {
  const { tripId } = useParams();
  const [tls, setTls] = useState([]);

  useEffect(() => {
    axios
      .get(`/api/v1/trips/${tripId}/trip_locations`)
      .then((res) => setTls(res.data || []))
      .catch((err) => console.error(err));
  }, [tripId]);

  return (
    <Container>
      <Typography variant="h4" gutterBottom>Recorrido del Viaje</Typography>

      {/* Placeholder de mapa */}
      <Card sx={{ mb: 2 }}>
        <CardContent>
          <Box
            sx={{
              width: "100%", height: 360, borderRadius: 2,
              bgcolor: "grey.200", display: "flex", alignItems: "center", justifyContent: "center",
              border: "1px dashed", borderColor: "grey.400"
            }}
          >
            <Typography color="text.secondary">
              Mapa próximamente — mostrando {tls.length} punto(s)
            </Typography>
          </Box>
        </CardContent>
      </Card>

      {/* Lista/itinerario */}
      <Card>
        <CardContent>
          <Typography variant="h6" gutterBottom>Itinerario</Typography>
          <List dense>
            {tls.map((tl) => (
              <ListItem
                key={tl.id}
                secondaryAction={
                  <Stack direction="row" spacing={1}>
                    <Button
                      component={RouterLink}
                      to={`/trip_locations/${tl.id}/posts`}
                      size="small"
                      variant="outlined"
                    >
                      Ver posts
                    </Button>
                  </Stack>
                }
              >
                <ListItemText
                  primary={tl.location?.name || `Location #${tl.location_id}`}
                  secondary={`pos ${tl.position} • lat ${tl.location?.latitude ?? "–"} • lng ${tl.location?.longitude ?? "–"} • check-in: ${tl.visited_at || "–"}`}
                />
              </ListItem>
            ))}
          </List>
        </CardContent>
      </Card>
    </Container>
  );
}