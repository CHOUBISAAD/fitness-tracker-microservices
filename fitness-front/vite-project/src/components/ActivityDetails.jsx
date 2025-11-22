import React from 'react'
import { useParams } from 'react-router-dom'
import { getActivityDetail } from '../api/axios';
import { Box, Card, CardContent, Typography, Chip, Stack, Divider, List, ListItem, ListItemText } from '@mui/material';

function ActivityDetails() {

  const [recommendation, setRecommendation] = React.useState(null);
  const [loading, setLoading] = React.useState(true);
  const { id } = useParams();
  console.log(id); // Replace with actual ID from route params

  // Fetch when id changes

  React.useEffect(() => {
    let active = true;
    const run = async () => {
      if (!id) return;
      setLoading(true);
      try {
        const response = await getActivityDetail(id);
        const data = response?.data;
        console.log('Fetched recommendation:', data);
        if (active) setRecommendation(data ?? null);
      } catch (error) {
        const status = error?.response?.status;
        console.error('Error fetching recommendation:', status ? `${status} ${error.response.statusText}` : error);
        if (active) setRecommendation(null);
      } finally {
        if (active) setLoading(false);
      }
    };
    run();
    return () => { active = false; };
  }, [id]);

  if (loading) return <Typography sx={{ p: 2 }}>Loading...</Typography>;
  if (!recommendation) return <Typography sx={{ p: 2 }}>No recommendation found</Typography>;

  const { activityType, recommendation: recText, improvements, suggestions, safety, createdAt, id: recId, activityId, userId } = recommendation;

  const paragraphs = (recText || '').split('\n').map(s => s.trim()).filter(Boolean);

  return (
    <Box sx={{ p: 2 }}>
      <Stack direction="row" spacing={1} alignItems="center" sx={{ mb: 2 }}>
        <Typography variant="h5">Recommendation</Typography>
        {activityType && <Chip label={activityType} color="primary" variant="outlined" />}
      </Stack>

      <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
        {createdAt ? new Date(createdAt).toLocaleString() : ''}
      </Typography>

      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Typography variant="h6" sx={{ mb: 1 }}>Overview</Typography>
          {paragraphs.length ? (
            <Stack spacing={1}>
              {paragraphs.map((p, i) => (
                <Typography key={i} variant="body1">{p}</Typography>
              ))}
            </Stack>
          ) : (
            <Typography variant="body2" color="text.secondary">No detailed text available.</Typography>
          )}
        </CardContent>
      </Card>

      {(Array.isArray(improvements) && improvements.length) && (
        <Card sx={{ mb: 3 }}>
          <CardContent>
            <Typography variant="h6" sx={{ mb: 1 }}>Improvements</Typography>
            <List>
              {improvements.map((item, idx) => (
                <ListItem key={idx} disableGutters>
                  <ListItemText primary={item} />
                </ListItem>
              ))}
            </List>
          </CardContent>
        </Card>
      )}

      {(Array.isArray(suggestions) && suggestions.length) && (
        <Card sx={{ mb: 3 }}>
          <CardContent>
            <Typography variant="h6" sx={{ mb: 1 }}>Suggestions</Typography>
            <List>
              {suggestions.map((item, idx) => (
                <ListItem key={idx} disableGutters>
                  <ListItemText primary={item} />
                </ListItem>
              ))}
            </List>
          </CardContent>
        </Card>
      )}

      {(Array.isArray(safety) && safety.length) && (
        <Card>
          <CardContent>
            <Typography variant="h6" sx={{ mb: 1 }}>Safety</Typography>
            <List>
              {safety.map((item, idx) => (
                <ListItem key={idx} disableGutters>
                  <ListItemText primary={item} />
                </ListItem>
              ))}
            </List>
          </CardContent>
        </Card>
      )}

      <Divider sx={{ my: 3 }} />
      <Typography variant="caption" color="text.secondary">
        Recommendation ID: {recId} | Activity ID: {activityId} | User: {userId}
      </Typography>
    </Box>
  )
}

export default ActivityDetails