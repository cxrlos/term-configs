// Preferred: run gen-config.sh to pull secrets from Bitwarden automatically.
// Manual fallback: copy this file to config.js and fill in values.

window.STRAVA_CREDS = {
  clientId:     '',
  clientSecret: '',
  refreshToken: '',
};

// GH data is provided by gh-data.js (refresh-gh.sh via gh CLI). Token unused.
window.GH_CREDS = { token: '' };

// Alpha Vantage free tier — https://www.alphavantage.co/support/#api-key
window.AV_KEY = '';
