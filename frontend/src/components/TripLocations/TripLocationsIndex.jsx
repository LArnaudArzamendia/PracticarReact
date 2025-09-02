import { useEffect, useState } from "react";
import { useParams, Link } from "react-router-dom";
import { Container, Typography, Card, CardContent, CardActionArea, Breadcrumbs } from "@mui/material";
import axios from "axios";

function TripLocationsIndex() {
  const { tripId } = useParams();
  const [locations, setLocations] = useState([]);
  const [error, setError] = useState(null);

  useEffect(() => {
    axios.get(`/api/v1/trips/${tripId}/trip_locations`)
      .then(res => setLocations(res.data))
      .catch(err => setError(err.message));
  }, [tripId]);

  return (
    <Container>
      <Breadcrumbs sx={{ mb: 2 }}>
        <Link to="/trips">Trips</Link>
        <Typography color="text.secondary">Trip {tripId}</Typography>
      </Breadcrumbs>
      <Typography variant="h4" gutterBottom>Trip Locations</Typography>
      {error && <Typography color="error" sx={{ mb: 2 }}>{error}</Typography>}
      {locations.map(loc => (
        <Card key={loc.id} sx={{ mb: 2 }}>
          <CardActionArea component={Link} to={`/trip_locations/${loc.id}/posts`}>
            <CardContent>
              <Typography variant="h6">{loc.name || `Location #${loc.id}`}</Typography>
              <Typography variant="body2">{loc.visited_at || ''}</Typography>
            </CardContent>
          </CardActionArea>
        </Card>
      ))}
    </Container>
  );
}

export default TripLocationsIndex;