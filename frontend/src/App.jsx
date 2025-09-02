import { BrowserRouter as Router, Routes, Route, Link } from "react-router-dom";
import { AppBar, Toolbar, Typography, Button, Container } from "@mui/material";

import Home from "./components/Home";
import Welcome from "./components/Welcome";
import TripsIndex from "./components/Trips/TripsIndex.jsx";
import TripLocationsIndex from "./components/TripLocations/TripLocationsIndex";
import PostsIndex from "./components/Posts/PostsIndex";
import TripMap from "./components/TripMap/TripMap";
import UserSearch from "./components/Users/UserSearch";
import UserProfile from "./components/Users/UserProfile";
import RequireAuth from "./components/RequireAuth";
import { useAuth } from "./context/AuthContext";

function App() {
  const { isAuthed, logout } = useAuth();

  return (
    <Router>
      <AppBar position="static">
        <Toolbar>
          <Typography variant="h6" sx={{ flexGrow: 1 }}>
            TravelLife
          </Typography>
          <Button color="inherit" component={Link} to="/">Home</Button>
          <Button color="inherit" component={Link} to="/trips">Trips</Button>
          <Button color="inherit" component={Link} to="/users/search">Users</Button>
          <Button color="inherit" component={Link} to="/welcome">Welcome</Button>
          {isAuthed && (
            <Button color="inherit" onClick={logout}>Logout</Button>
          )}
        </Toolbar>
      </AppBar>

      <Container sx={{ mt: 3 }}>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/welcome" element={<Welcome />} />

          {/* Rutas protegidas */}
          <Route path="/trips" element={
            <RequireAuth><TripsIndex /></RequireAuth>
          } />
          <Route path="/trips/:tripId/locations" element={
            <RequireAuth><TripLocationsIndex /></RequireAuth>
          } />
          <Route path="/trips/:tripId/map" element={
            <RequireAuth><TripMap /></RequireAuth>
          } />
          <Route path="/trip_locations/:tripLocationId/posts" element={
            <RequireAuth><PostsIndex /></RequireAuth>
          } />

          <Route path="/users/search" element={<UserSearch />} />
          <Route path="/users/:id" element={<UserProfile />} />

          <Route path="*" element={<h2>404 Not Found</h2>} />
        </Routes>
      </Container>
    </Router>
  );
}

export default App;