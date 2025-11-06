// Application startup file for Passenger/cPanel
// This file serves the built static files from Vite
// Note: This file uses CommonJS (require) for compatibility with Passenger

const express = require('express');
const path = require('path');
const app = express();

// Get the port from environment variable (Passenger sets this automatically)
const PORT = process.env.PORT || process.env.PASSENGER_PORT || 3000;

// Serve static files from the dist directory (Vite build output)
const distPath = path.join(__dirname, 'dist');
app.use(express.static(distPath));

// Handle client-side routing - all routes should serve index.html
// This is important for React Router to work correctly
app.get('*', (req, res) => {
  res.sendFile(path.join(distPath, 'index.html'));
});

// Start the server
// Passenger will automatically detect and use this app
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
    console.log(`Serving files from: ${distPath}`);
  });
}

// Export app for Passenger
module.exports = app;

