import React from 'react';
import AppBar from '@mui/material/AppBar';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import IconButton from '@mui/material/IconButton';
import Container from '@mui/material/Container';
import FitnessCenterIcon from '@mui/icons-material/FitnessCenter';
import LogoutIcon from '@mui/icons-material/Logout';
import Button from '@mui/material/Button';
import Stack from '@mui/material/Stack';
import Box from '@mui/material/Box';
import { useDispatch } from 'react-redux';
import { logout as logoutAction } from '../store/authSlice';
import { logout as oauthLogout } from '../auth/simpleOAuth';

export default function AppLayout({ onLogout, children }) {
  const dispatch = useDispatch();

  const handleLogout = () => {
    dispatch(logoutAction());
    oauthLogout();
    if (onLogout) onLogout();
    window.location.href = '/';
  };

  return (
    <Box sx={{ minHeight: '100vh', display: 'flex', flexDirection: 'column' }}>
      <AppBar position="sticky" elevation={0}>
        <Toolbar>
          <FitnessCenterIcon color="primary" sx={{ mr: 1 }} />
          <Typography variant="h6" sx={{ flexGrow: 1, fontWeight: 700 }}>
            FitTrack
          </Typography>
          <Stack direction="row" spacing={1} alignItems="center">
            <Button size="small" variant="outlined" color="secondary" startIcon={<LogoutIcon />} onClick={handleLogout}>
              Log out
            </Button>
          </Stack>
        </Toolbar>
      </AppBar>
      <Container maxWidth="lg" sx={{ py: 3, flex: 1 }}>{children}</Container>
      <Box component="footer" sx={{ py: 2, textAlign: 'center', color: 'text.secondary' }}>
        <Typography variant="caption">© {new Date().getFullYear()} FitTrack</Typography>
      </Box>
    </Box>
  );
}
