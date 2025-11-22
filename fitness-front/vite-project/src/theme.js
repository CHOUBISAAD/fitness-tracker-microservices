import { createTheme } from '@mui/material/styles';

const theme = createTheme({
  palette: {
    mode: 'light',
    primary: {
      main: '#16a34a', // emerald
      light: '#4ade80',
      dark: '#15803d',
      contrastText: '#ffffff',
    },
    secondary: {
      main: '#f97316', // orange
      light: '#fb923c',
      dark: '#ea580c',
      contrastText: '#111827',
    },
    background: {
      default: '#0b1220',
      paper: '#0f172a',
    },
    text: {
      primary: '#e5e7eb',
      secondary: '#cbd5e1',
    },
  },
  shape: { borderRadius: 12 },
  typography: {
    fontFamily: ['Inter', 'system-ui', 'Arial', 'sans-serif'].join(','),
    h5: { fontWeight: 700 },
    h6: { fontWeight: 600 },
    button: { textTransform: 'none', fontWeight: 600 },
  },
  components: {
    MuiCssBaseline: {
      styleOverrides: {
        body: {
          background: 'radial-gradient(1200px 600px at 10% -10%, rgba(34,197,94,0.15), transparent), radial-gradient(800px 400px at 110% 10%, rgba(249,115,22,0.12), transparent), linear-gradient(180deg, #0b1220 0%, #0b1220 100%)',
          minHeight: '100vh',
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        root: {
          backgroundColor: '#111827',
          border: '1px solid rgba(148,163,184,0.15)',
          boxShadow: '0 10px 30px rgba(0,0,0,0.25)',
        },
      },
    },
    MuiAppBar: {
      styleOverrides: {
        root: { backgroundColor: '#0b1220', borderBottom: '1px solid rgba(148,163,184,0.15)' },
      },
    },
  },
});

export default theme;
