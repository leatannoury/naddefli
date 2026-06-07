require('dotenv').config();

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
});

const express = require('express');
const cors = require('cors');
const path = require('path');
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
const addressRoutes = require('./routes/addressRoutes');
const promoRoutes = require('./routes/promoRoutes');
const addonRoutes = require('./routes/addonRoutes');
const cleaningTipRoutes = require('./routes/cleaningTipRoutes');
const adminController = require('./controllers/adminController');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/uploads', express.static(path.join(__dirname, '../public/uploads')));

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
app.use('/api/addresses', addressRoutes);
app.use('/api/promo', promoRoutes);
app.use('/api/addons', addonRoutes);
app.use('/api/cleaning-tips', cleaningTipRoutes);
app.get('/api/settings/public', adminController.getPublicSettings);

// Development-only debug endpoints
if (process.env.NODE_ENV === 'development') {
  const { User } = require('./models');
  const { hashPassword, generateToken } = require('./utils/helpers');

  app.post('/api/debug/create-admin', async (req, res) => {
    try {
      const { email = 'admin@local.test', full_name = 'Local Admin', password = 'password123' } = req.body || {};
      let user = await User.findOne({ where: { email } });
      if (!user) {
        const hashed = await hashPassword(password);
        user = await User.create({ full_name, email, password: hashed, role: 'admin' });
      }
      const token = generateToken({ id: user.id, email: user.email, role: user.role });
      return res.status(201).json({ success: true, data: { user: { id: user.id, email: user.email, full_name: user.full_name }, token } });
    } catch (err) {
      console.error('Debug create-admin error:', err);
      return res.status(500).json({ success: false, message: 'Failed to create admin', error: err.message });
    }
  });
}

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
  const tables = await queryInterface.showAllTables();

  // 1. Ensure Addresses Table exists
  if (!tables.includes('addresses')) {
    await sequelize.models.Address.sync();
    console.log('✅ Created addresses table');
  }

  // 2. Ensure Promo Codes Table exists
  if (!tables.includes('promo_codes')) {
    await sequelize.models.PromoCode.sync();
    console.log('✅ Created promo_codes table');
  }

  // 3. Check and add columns to users table
  const usersTable = await queryInterface.describeTable('users');
  if (!usersTable.loyalty_points) {
    await queryInterface.addColumn('users', 'loyalty_points', {
      type: DataTypes.INTEGER,
      defaultValue: 0,
      allowNull: false,
    });
    console.log('✅ Added loyalty_points column to users table');
  }
  if (!usersTable.completed_bookings_count) {
    await queryInterface.addColumn('users', 'completed_bookings_count', {
      type: DataTypes.INTEGER,
      defaultValue: 0,
      allowNull: false,
    });
    console.log('✅ Added completed_bookings_count column to users table');
  }
  if (!usersTable.loyalty_progress) {
    await queryInterface.addColumn('users', 'loyalty_progress', {
      type: DataTypes.INTEGER,
      defaultValue: 0,
      allowNull: false,
    });
    await sequelize.query(
      'UPDATE users SET loyalty_progress = completed_bookings_count % 4'
    );
  }
  if (!usersTable.loyalty_rewards_available) {
    await queryInterface.addColumn('users', 'loyalty_rewards_available', {
      type: DataTypes.INTEGER,
      defaultValue: 0,
      allowNull: false,
    });
    await sequelize.query(
      'UPDATE users SET loyalty_rewards_available = CAST(loyalty_points / 4 AS INTEGER)'
    );
  }
  if (!usersTable.is_blocked) {
    await queryInterface.addColumn('users', 'is_blocked', {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
      allowNull: false,
    });
    console.log('✅ Added is_blocked column to users table');
  }

  // 3b. Check and add columns to services table
  const servicesTable = await queryInterface.describeTable('services');
  if (!servicesTable.add_ons) {
    await queryInterface.addColumn('services', 'add_ons', {
      type: DataTypes.TEXT,
      allowNull: true,
    });
    console.log('✅ Added add_ons column to services table');
  }
  if (!servicesTable.is_active) {
    await queryInterface.addColumn('services', 'is_active', {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
      allowNull: false,
    });
    console.log('✅ Added is_active column to services table');
  }
  if (!servicesTable.image) {
    await queryInterface.addColumn('services', 'image', {
      type: DataTypes.TEXT,
      allowNull: true,
    });
    console.log('✅ Added image column to services table');
  }

  // 3c. Check and add columns to promo_codes table
  const promoCodesTable = await queryInterface.describeTable('promo_codes');
  if (!promoCodesTable.is_active) {
    await queryInterface.addColumn('promo_codes', 'is_active', {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
      allowNull: false,
    });
    console.log('✅ Added is_active column to promo_codes table');
  }
  if (!promoCodesTable.is_hot_offer) {
    await queryInterface.addColumn('promo_codes', 'is_hot_offer', {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
      allowNull: false,
    });
    console.log('✅ Added is_hot_offer column to promo_codes table');
  }
  if (!promoCodesTable.description) {
    await queryInterface.addColumn('promo_codes', 'description', {
      type: DataTypes.STRING(255),
      allowNull: true,
    });
    console.log('✅ Added description column to promo_codes table');
  }

  // 3d. Ensure add_ons table exists
  if (!tables.includes('add_ons')) {
    await sequelize.models.AddOn.sync();
    console.log('✅ Created add_ons table');
  }

  // 3e. Ensure cleaning_tips table exists and seed defaults
  if (!tables.includes('cleaning_tips')) {
    await sequelize.models.CleaningTip.sync();
    console.log('✅ Created cleaning_tips table');
  }
  const CleaningTip = sequelize.models.CleaningTip;
  const tipCount = await CleaningTip.count();
  if (tipCount === 0) {
    await CleaningTip.bulkCreate([
      {
        title: 'Cloudy Day Window Trick',
        content: 'Clean windows on cloudy days to avoid streaks from quick drying in direct sunlight.',
        gradient_start: '#0058BC',
        gradient_end: '#0070EB',
      },
      {
        title: 'Natural Odor Remover',
        content: 'Sprinkle baking soda on carpets and upholstery, let sit 15 minutes, then vacuum to remove odors.',
        gradient_start: '#312E81',
        gradient_end: '#6366F1',
      },
      {
        title: 'Vacuum Before Mopping',
        content: 'Always vacuum hard floors before mopping so dirt does not turn into muddy streaks.',
        gradient_start: '#0F766E',
        gradient_end: '#14B8A6',
      },
      {
        title: 'Top-Down Cleaning',
        content: 'Dust shelves and wipe surfaces from top to bottom so falling dust does not re-soil cleaned areas.',
        gradient_start: '#9A3412',
        gradient_end: '#F97316',
      },
      {
        title: 'Microfiber Magic',
        content: 'Use damp microfiber cloths for dusting — they trap particles better than feather dusters.',
        gradient_start: '#4C4ACA',
        gradient_end: '#6664E4',
      },
    ]);
    console.log('✅ Seeded default cleaning tips');
  }

  // 4. Check and add columns to bookings table
  const bookingsTable = await queryInterface.describeTable('bookings');
  const bookingColumns = {
    is_custom: { type: DataTypes.BOOLEAN, defaultValue: false },
    property_type: { type: DataTypes.STRING(50), allowNull: true },
    room_count: { type: DataTypes.INTEGER, defaultValue: 0 },
    bathrooms_count: { type: DataTypes.INTEGER, defaultValue: 0 },
    kitchens_count: { type: DataTypes.INTEGER, defaultValue: 0 },
    cleaning_type: { type: DataTypes.STRING(50), defaultValue: 'normal' },
    extras: { type: DataTypes.TEXT, allowNull: true },
    start_time: { type: DataTypes.STRING(5), allowNull: true },
    end_time: { type: DataTypes.STRING(5), allowNull: true },
    duration_hours: { type: DataTypes.DECIMAL(5, 2), defaultValue: 1.0 },
    discount_amount: { type: DataTypes.DECIMAL(10, 2), defaultValue: 0.0 },
    promo_code: { type: DataTypes.STRING(50), allowNull: true },
    loyalty_reward_earned: { type: DataTypes.BOOLEAN, defaultValue: false, allowNull: false },
    loyalty_reward_redeemed: { type: DataTypes.BOOLEAN, defaultValue: false, allowNull: false },
  };

  for (const [name, definition] of Object.entries(bookingColumns)) {
    if (!bookingsTable[name]) {
      await queryInterface.addColumn('bookings', name, definition);
      console.log(`✅ Added missing column ${name} to bookings table`);
    }
  }

  // 5. Seed promo codes if they are missing
  const PromoCode = sequelize.models.PromoCode;
  const count = await PromoCode.count();
  if (count === 0) {
    await PromoCode.bulkCreate([
      {
        code: 'DEEP20',
        type: 'percentage',
        value: 20.0,
        conditions: JSON.stringify({ cleaning_type: 'deep' }),
        expires_at: new Date('2030-12-31'),
      },
      {
        code: 'FIRST10',
        type: 'percentage',
        value: 10.0,
        conditions: JSON.stringify({ first_booking: true }),
        expires_at: new Date('2030-12-31'),
      },
      {
        code: 'WINDOWFREE',
        type: 'free_addon',
        value: 10.0,
        conditions: JSON.stringify({ free_addon: 'Windows Cleaning' }),
        expires_at: new Date('2030-12-31'),
      },
    ]);
    console.log('✅ Seeded default promo codes (DEEP20, FIRST10, WINDOWFREE)');
  }
};

// Database connection and server start
const startServer = async () => {
  try {
    try {
      await sequelize.authenticate();
      console.log('✅ Database connection established successfully');
    } catch (dbError) {
      console.warn('⚠️ Database connection warning:', dbError.message);
      console.log('ℹ️ Continuing with manually created database schema');
    }

    await ensureBookingColumns();

    console.log('✅ Database ready');

    const PORT = process.env.PORT || 5000;
    app.listen(PORT, () => {
      console.log(`✅ Server running on http://localhost:${PORT}`);
      console.log(`📚 API Documentation:`);
      console.log(`   - Auth: POST /api/auth/register, POST /api/auth/login`);
      console.log(`   - Services: GET /api/services`);
      console.log(`   - Bookings: POST /api/bookings/create, GET /api/bookings/my-bookings`);
      console.log(`   - Addresses: GET /api/addresses, POST /api/addresses`);
      console.log(`   - Promos: POST /api/promo/validate`);
      console.log(`   - Health: GET /api/health`);
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
};

startServer();
