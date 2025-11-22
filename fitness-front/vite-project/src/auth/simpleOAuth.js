// Standard OAuth2 (Authorization Code Flow without PKCE)
export const authConfig = {
  clientId: 'fitness-tracker-frontend',
  authorizationEndpoint: 'http://a2fb1d62de83c4cf19a363056cc94295-1756053402.eu-west-1.elb.amazonaws.com:8080/realms/fitness-tracker/protocol/openid-connect/auth',
  tokenEndpoint: 'http://a2fb1d62de83c4cf19a363056cc94295-1756053402.eu-west-1.elb.amazonaws.com:8080/realms/fitness-tracker/protocol/openid-connect/token',
  redirectUri: 'http://a36142eb10bca4c36a3e2104d30b0103-2138269119.eu-west-1.elb.amazonaws.com/',
  scope: 'openid profile email',
};

// Simple OAuth2 utilities (no PKCE)
export const generateRandomState = () => {
  return Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
};

export const initiateLogin = () => {
  const state = generateRandomState();
  sessionStorage.setItem('oauth_state', state);

  const params = new URLSearchParams({
    client_id: authConfig.clientId,
    redirect_uri: authConfig.redirectUri,
    response_type: 'code',
    scope: authConfig.scope,
    state: state,
  });

  window.location.href = `${authConfig.authorizationEndpoint}?${params.toString()}`;
};

// Decode JWT token to get user info
const decodeToken = (token) => {
  try {
    const base64Url = token.split('.')[1];
    const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
    const jsonPayload = decodeURIComponent(atob(base64).split('').map((c) => {
      return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
    }).join(''));
    return JSON.parse(jsonPayload);
  } catch (error) {
    console.error('Error decoding token:', error);
    return null;
  }
};

export const handleCallback = async () => {
  const urlParams = new URLSearchParams(window.location.search);
  const code = urlParams.get('code');
  const state = urlParams.get('state');
  const savedState = sessionStorage.getItem('oauth_state');

  if (!code || state !== savedState) {
    console.error('Invalid OAuth callback');
    return null;
  }

  sessionStorage.removeItem('oauth_state');

  // Exchange code for token
  const tokenParams = new URLSearchParams({
    grant_type: 'authorization_code',
    code: code,
    redirect_uri: authConfig.redirectUri,
    client_id: authConfig.clientId,
  });

  try {
    const response = await fetch(authConfig.tokenEndpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: tokenParams.toString(),
    });

    if (!response.ok) {
      throw new Error('Token exchange failed');
    }

    const tokens = await response.json();
    
    // Decode access token to get user ID
    const decodedToken = decodeToken(tokens.access_token);
    const userId = decodedToken?.sub || decodedToken?.user_id || decodedToken?.preferred_username;
    
    localStorage.setItem('access_token', tokens.access_token);
    localStorage.setItem('token', tokens.access_token); // For Redux
    localStorage.setItem('refresh_token', tokens.refresh_token);
    localStorage.setItem('id_token', tokens.id_token);
    localStorage.setItem('userId', userId);
    
    console.log('User authenticated:', userId);
    
    // Clear the URL
    window.history.replaceState({}, document.title, window.location.pathname);
    
    return tokens;
  } catch (error) {
    console.error('Error exchanging code for token:', error);
    return null;
  }
};

export const getAccessToken = () => {
  return localStorage.getItem('access_token');
};

export const logout = () => {
  localStorage.removeItem('access_token');
  localStorage.removeItem('token');
  localStorage.removeItem('refresh_token');
  localStorage.removeItem('id_token');
  localStorage.removeItem('userId');
  sessionStorage.removeItem('oauth_state');
};

export const isAuthenticated = () => {
  return !!getAccessToken();
};
