const express = require('express');
const healthRouter = require('./routes/health');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Routes
app.use('/health', healthRouter);

app.get('/', (req, res) => {
  res.json({
    message: 'Welcome to My AWS App',
    environment: process.env.NODE_ENV || 'development',
    version: '1.0.0'
  });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
});

module.exports = app;