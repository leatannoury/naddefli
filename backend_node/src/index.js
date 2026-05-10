require('dotenv').config();

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
  // Optionally: process.exit(1);
});

const express = require('express');
const cors = require('cors');
const { DataTypes } = require('sequelize');
const sequelize = require('./config/db');
const { initializeAssociations } = require('./models');
const errorHandler = require('./middleware/errorHandler');

// Import routes
const authRoutes = require('./routes/authRoutes');
const serviceRoutes = require('./routes/serviceRoutes');
const bookingRoutes = require('./routes/bookingRoutes');
const cleanerRoutes = require('./routes/cleanerRoutes');
const reviewRoutes = require('./routes/reviewRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const adminRoutes = require('./routes/adminRoutes');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Initialize model associations
initializeAssociations();

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/services', serviceRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/cleaner', cleanerRoutes);
app.use('/api/reviews', reviewRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/admin', adminRoutes);

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Server is running',
    timestamp: new Date(),
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found',
  });
});

// Error handling middleware
app.use(errorHandler);

const ensureBookingColumns = async () => {
  const queryInterface = sequelize.getQueryInterface();
  
  // Check if bookings table exists
  const tables = await queryInterface.showAllTables();
  if (!tables.includes('bookings')) {
    console.log('ℹ️ Bookings table does not exist, skipping column check');
    return;
  }

  const table = await queryInterface.describeTable('bookings');

  const columns = {
    is_custom: { type: DataTypes.BOOLEAN, defaultValue: false },
    property_type: { type: DataTypes.STRING(50), allowNull: true },
    room_count: { type: DataTypes.INTEGER, defaultValue: 0 },
    bathrooms_count: { type: DataTypes.INTEGER, defaultValue: 0 },
    kitchens_count: { type: DataTypes.INTEGER, defaultValue: 0 },
    cleaning_type: { type: DataTypes.STRING(50), defaultValue: 'normal' },
    extras: { type: DataTypes.TEXT, allowNull: true },
  };

  for (const [name, definition] of Object.entries(columns)) {
    if (!table[name]) {
      await queryInterface.addColumn('bookings', name, definition);
      console.log(`✅ Added missing column ${name} to bookings table`);
    }
  }
};

// Database connection and server start
const startServer = async () => {
  try {
    // Try to authenticate database, but continue anyway
    try {
      await sequelize.authenticate();
      console.log('✅ Database connection established successfully');
    } catch (dbError) {
      console.warn('⚠️ Database connection warning:', dbError.message);
      console.log('ℹ️ Continuing with manually created database schema');
    }

    await ensureBookingColumns();

    // Skip sync since we manually created tables
    // await sequelize.sync({ alter: false });
    console.log('✅ Database ready');

    // Start server
    const PORT = process.env.PORT || 5000;
    app.listen(PORT, () => {
      console.log(`✅ Server running on http://localhost:${PORT}`);
      console.log(`📚 API Documentation:`);
      console.log(`   - Auth: POST /api/auth/register, POST /api/auth/login`);
      console.log(`   - Services: GET /api/services`);
      console.log(`   - Bookings: POST /api/bookings/create, GET /api/bookings/my-bookings`);
      console.log(`   - Health: GET /api/health`);
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
};

startServer();
