import { useEffect, useState } from "react";
import {
  Container, Typography, TextField, Button, Card, CardContent, Stack
} from "@mui/material";
import { useLocation, Link as RouterLink } from "react-router-dom";
import axios from "axios";

function useQuery() {
  const { search } = useLocation();
  return new URLSearchParams(search);
}

export default function UserSearch() {
  const queryParams = useQuery();
  const initial = queryParams.get("handle") || "";
  const [query, setQuery] = useState(initial);
  const [results, setResults] = useState([]);
  const [loading, setLoading] = useState(false);

  const performSearch = () => {
    const q = query.trim();
    if (!q) { setResults([]); return; }
    setLoading(true);
    axios.get(`/api/v1/users/search`, { params: { handle: q } })
      .then(res => setResults(res.data || []))
      .catch(err => console.error(err))
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    if (initial) performSearch();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [initial]);

  return (
    <Container>
      <Typography variant="h4" gutterBottom>Buscar Usuarios</Typography>
      <Stack direction="row" spacing={2} sx={{ mb: 2 }}>
        <TextField
          label="Handle (ej: @buddy)"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          onKeyDown={(e) => e.key === "Enter" && performSearch()}
          fullWidth
        />
        <Button variant="contained" onClick={performSearch} disabled={loading}>
          {loading ? "Buscando..." : "Buscar"}
        </Button>
      </Stack>

      {results.length === 0 && !loading && (
        <Typography color="text.secondary">Sin resultados.</Typography>
      )}

      <Stack spacing={2}>
        {results.map(u => (
          <Card key={u.id}>
            <CardContent>
              <Typography variant="h6">{u.handle}</Typography>
              <Typography variant="body2" color="text.secondary">{u.email}</Typography>
              <Button component={RouterLink} to={`/users/${u.id}`} sx={{ mt: 1 }} variant="outlined">
                Ver perfil
              </Button>
            </CardContent>
          </Card>
        ))}
      </Stack>
    </Container>
  );
}