import { useEffect, useState } from "react";
import { Container, Typography, Card, CardContent, CardActionArea } from "@mui/material";
import { Link } from "react-router-dom";
import axios from "axios";

function TripsIndex() {
  const [trips, setTrips] = useState([]);
  const [error, setError] = useState(null);

  useEffect(() => {
    axios.get("/api/v1/trips")
      .then(res => setTrips(res.data))
      .catch(err => setError(err.message));
  }, []);

  return (
    <Container>
      <Typography variant="h4" gutterBottom>My Trips</Typography>
      {error && <Typography color="error" sx={{ mb: 2 }}>{error}</Typography>}
      {trips.map(trip => (
        <Card key={trip.id} sx={{ mb: 2 }}>
          <CardActionArea component={Link} to={`/trips/${trip.id}/locations`}>
            <CardContent>
              <Typography variant="h6">{trip.title}</Typography>
              <Typography variant="body2">{trip.description}</Typography>
            </CardContent>
          </CardActionArea>
        </Card>

      ))}
    </Container>
  );
}

export default TripsIndex;