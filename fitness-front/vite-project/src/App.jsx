import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { setCredentials } from './store/authSlice';
import { ThemeProvider, CssBaseline, Container, Typography, Stack, Box, Button } from '@mui/material';
import ActivityForm from './components/ActivityForm';
import ActivityList from './components/ActivityList';
import ActivityDetails from './components/ActivityDetails';
import AppLayout from './components/AppLayout';
import theme from './theme';
import { initiateLogin, handleCallback, isAuthenticated, getAccessToken } from './auth/simpleOAuth';

const ActivitiesPage = () => (
  <Box component="section" sx={{ p: 2 }}>
    <ActivityForm onActivityAdded={() => { window.location.reload(); }} />
    <ActivityList />
  </Box>
);

function App() {
  const [isLoading, setIsLoading] = useState(true);
  const reduxToken = useSelector((state) => state.auth.token);
  const dispatch = useDispatch();

  useEffect(() => {
    const initAuth = async () => {
      // Check if we're returning from OAuth callback
      const urlParams = new URLSearchParams(window.location.search);
      if (urlParams.has('code')) {
        const tokens = await handleCallback();
        if (tokens) {
          // userId is already stored in localStorage by handleCallback
          dispatch(setCredentials({ token: tokens.access_token, user: {} }));
        }
      } else if (isAuthenticated()) {
        // User already has token
        const token = getAccessToken();
        dispatch(setCredentials({ token, user: {} }));
      }
      setIsLoading(false);
    };
    
    initAuth();
  }, [dispatch]);

  if (isLoading) {
    return <div>Loading...</div>;
  }

  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Router>
        {!reduxToken ? (
          <Container maxWidth="md" sx={{ py: 10 }}>
            <Stack spacing={3} alignItems="center" textAlign="center">
              <Typography variant="h3" fontWeight={800}>
                Track. Improve. Thrive.
              </Typography>
              <Typography variant="body1" color="text.secondary">
                Sign in to start logging your workouts and get smart recommendations.
              </Typography>
              <Button size="large" variant="contained" color="primary" onClick={initiateLogin}>
                Log in to Continue
              </Button>
            </Stack>
          </Container>
        ) : (
          <AppLayout>
            <Routes>
              <Route path="/activities" element={<ActivitiesPage />} />
              <Route path="/activities/:id" element={<ActivityDetails />} />
              <Route path="/" element={reduxToken ? <Navigate to="/activities" /> : <Navigate to="/login" />} />
            </Routes>
          </AppLayout>
        )}
      </Router>
    </ThemeProvider>
  )
}

export default App;


