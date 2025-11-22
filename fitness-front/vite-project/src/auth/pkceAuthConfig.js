
export const authConfig = {
  clientId: 'fitness-tracker-frontend',
  authorizationEndpoint: 'http://a2fb1d62de83c4cf19a363056cc94295-1756053402.eu-west-1.elb.amazonaws.com:8080/realms/fitness-tracker/protocol/openid-connect/auth',
  tokenEndpoint: 'http://a2fb1d62de83c4cf19a363056cc94295-1756053402.eu-west-1.elb.amazonaws.com:8080/realms/fitness-tracker/protocol/openid-connect/token',
  redirectUri: 'http://a36142eb10bca4c36a3e2104d30b0103-2138269119.eu-west-1.elb.amazonaws.com/',
  scope: 'openid profile email',
  // Standard OAuth2 flow (not PKCE) since we don't have HTTPS
  autoLogin: false,
  onRefreshTokenExpire: (event) => event.logIn(),
}