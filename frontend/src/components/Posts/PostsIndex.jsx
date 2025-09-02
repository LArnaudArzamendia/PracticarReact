import { useEffect, useState } from "react";
import { useParams, Link as RouterLink } from "react-router-dom";
import {
  Container, Typography, ImageList, ImageListItem, ImageListItemBar,
  Card, CardContent, Chip, Box, Stack, Divider
} from "@mui/material";
import axios from "axios";

function RichTextWithMentions({ text }) {
  if (!text) return null;
  const parts = text.split(/(@[A-Za-z0-9_]+)/g);
  return (
    <span>
      {parts.map((p, i) => {
        if (p.startsWith("@")) {
          const handle = p.slice(1);
          return (
            <RouterLink key={i} to={`/users/search?handle=${encodeURIComponent(handle)}`}>
              {p}
            </RouterLink>
          );
        }
        return <span key={i}>{p}</span>;
      })}
    </span>
  );
}

export default function PostsIndex() {
  const { tripLocationId } = useParams();
  const [posts, setPosts] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setLoading(true);
    axios
      .get(`/api/v1/posts?trip_location_id=${tripLocationId}`, { params: { trip_location_id: tripLocationId } })
      .then((res) => setPosts(res.data || []))
      .catch((err) => console.error(err))
      .finally(() => setLoading(false));
  }, [tripLocationId]);

  const mediaItems = [];
  posts.forEach((p) => {
    (p.pictures || []).forEach((pic) => {
      mediaItems.push({ type: "image", post: p, data: pic });
    });
    (p.videos || []).forEach((vid) => {
      mediaItems.push({ type: "video", post: p, data: vid });
    });
  });

  return (
    <Container>
      <Typography variant="h4" gutterBottom>
        Galería de Publicaciones
      </Typography>

      {loading && <Typography>Cargando...</Typography>}

      {!loading && mediaItems.length === 0 && (
        <Card sx={{ mb: 2 }}>
          <CardContent>
            <Typography variant="body1">
              Aún no hay media en esta ubicación. Crea un Post desde el backend o sube una imagen/video.
            </Typography>
            <Divider sx={{ my: 2 }} />
            {posts.map((p) => (
              <Box key={p.id} sx={{ mb: 1 }}>
                <Typography variant="subtitle2">Post #{p.id}</Typography>
                <Typography variant="body2" color="text.secondary">
                  <RichTextWithMentions text={p.body} />
                </Typography>
              </Box>
            ))}
          </CardContent>
        </Card>
      )}

      <ImageList cols={3} gap={12} sx={{ mt: 1 }}>
        {mediaItems.map((item, idx) => {
          const { type, post, data } = item;

          if (type === "image") {
            const tags = data.tags || [];
            return (
              <ImageListItem key={`img-${data.id}-${idx}`} sx={{ position: "relative" }}>
                <img
                  src={data.url}
                  alt={data.caption || `picture-${data.id}`}
                  loading="lazy"
                  style={{ display: "block", width: "100%", height: "100%", objectFit: "cover", borderRadius: 8 }}
                />

                {}
                <Box sx={{ position: "absolute", inset: 0, pointerEvents: "none" }}>
                  {tags.map((t) => {
                    const top = t.y_frac != null ? `${t.y_frac * 100}%` : "50%";
                    const left = t.x_frac != null ? `${t.x_frac * 100}%` : "50%";
                    return (
                      <Chip
                        key={`tag-${t.id}`}
                        label={`@${t.handle}`}
                        size="small"
                        sx={{
                          position: "absolute",
                          top,
                          left,
                          transform: "translate(-50%, -50%)",
                          pointerEvents: "auto",
                          bgcolor: "rgba(0,0,0,0.5)",
                          color: "#fff",
                        }}
                        component={RouterLink}
                        to={`/users/search?handle=${encodeURIComponent(t.handle)}`}
                        clickable
                      />
                    );
                  })}
                </Box>

                <ImageListItemBar
                  title={data.caption || "Foto"}
                  subtitle={<RichTextWithMentions text={post.body} />}
                />
              </ImageListItem>
            );
          }

          return (
            <ImageListItem key={`vid-${data.id}-${idx}`}>
              <Box sx={{ position: "relative", borderRadius: 2, overflow: "hidden" }}>
                <video
                  src={data.url}
                  controls
                  style={{ display: "block", width: "100%", height: "100%", objectFit: "cover" }}
                />
              </Box>
              <ImageListItemBar
                title={data.caption || "Video"}
                subtitle={<RichTextWithMentions text={post.body} />}
              />
            </ImageListItem>
          );
        })}
      </ImageList>

      {}
      {posts.length > 0 && (
        <Box sx={{ mt: 3 }}>
          <Typography variant="h6" gutterBottom>Publicaciones</Typography>
          <Stack spacing={2}>
            {posts.map((p) => (
              <Card key={p.id}>
                <CardContent>
                  <Typography variant="subtitle2" sx={{ mb: 0.5 }}>
                    Post #{p.id} — {p.trip_location?.location?.name}
                  </Typography>
                  <Typography variant="body2">
                    <RichTextWithMentions text={p.body} />
                  </Typography>
                </CardContent>
              </Card>
            ))}
          </Stack>
        </Box>
      )}
    </Container>
  );
}