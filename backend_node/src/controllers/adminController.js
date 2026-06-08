const { User, Booking, Cleaner, Review, Service, PromoCode, Address, Notification } = require('../models');
const {
  hashPassword,
  comparePassword,
  generateToken,
  parseDashboardDateRange,
  formatServiceRecord,
  formatBookingRecord,
  resolveServiceImageUrl,
} = require('../utils/helpers');
const { sendSuccess, sendError } = require('../utils/response');
const sequelize = require('../config/db');
const { awardCleaningMilestone } = require('../utils/loyalty');
const { Op } = require('sequelize');
const fs = require('fs');
const path = require('path');

const SETTINGS_FILE_PATH = path.join(__dirname, '../config/settings.json');

/**
 * Helper to read settings
 */
const readSettings = () => {
  try {
    if (fs.existsSync(SETTINGS_FILE_PATH)) {
      const raw = fs.readFileSync(SETTINGS_FILE_PATH);
      return JSON.parse(raw);
    }
  } catch (err) {
    console.error('Error reading settings file:', err);
  }
  return {
    businessName: 'Naddefli Cleaning Services',
    supportPhone: '+1 (555) 019-2834',
    supportEmail: 'support@naddefli.com',
    normalHourlyRate: 4.0,
    deepHourlyRate: 6.0,
    currency: 'USD',
    timezone: 'UTC',
    bookingBufferHours: 2,
    autoConfirmBookings: false
    ,
    globalAddOns: []
  };
};

/**
 * Helper to write settings
 */
const writeSettings = (settings) => {
  try {
    const dir = path.dirname(SETTINGS_FILE_PATH);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    fs.writeFileSync(SETTINGS_FILE_PATH, JSON.stringify(settings, null, 2));
    return true;
  } catch (err) {
    console.error('Error writing settings file:', err);
    return false;
  }
};

/**
 * Admin Dedicated Login
 */
exports.adminLogin = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return sendError(res, 'Email and password are required', 400);
    }

    const user = await User.findOne({ where: { email } });
    if (!user) {
      return sendError(res, 'Invalid email or password', 401);
    }

    // Role verification
    if (user.role !== 'admin') {
      return sendError(res, 'Access denied. Administrator privileges required.', 403);
    }

    // Blocking check
    if (user.is_blocked) {
      return sendError(res, 'Your administrator account has been deactivated.', 403);
    }

    const passwordMatch = await comparePassword(password, user.password);
    if (!passwordMatch) {
      return sendError(res, 'Invalid email or password', 401);
    }

    const token = generateToken(user);

    sendSuccess(res, {
      user: {
        id: user.id,
        full_name: user.full_name,
        email: user.email,
        role: user.role,
      },
      token,
    }, 'Admin logged in successfully');
  } catch (error) {
    console.error('Admin login error:', error);
    sendError(res, 'Failed to login admin', 500, error);
  }
};

/**
 * Get dashboard statistics
 */
exports.getDashboard = async (req, res) => {
  try {
    const { startDate, endDate, hasRange, filterMode, dateField } = parseDashboardDateRange(req.query);

    const bookingWhere = {};
    if (hasRange) {
      bookingWhere[dateField] = { [Op.between]: [startDate, endDate] };
    }

    const pendingAllTime = await Booking.count({ where: { status: 'pending' } });

    // Total customers (users with role customer) - all time
    const totalUsers = await User.count({
      where: { role: 'customer' },
    });

    // Total cleaners - all time
    const totalCleaners = await User.count({
      where: { role: 'cleaner' },
    });

    // Bookings by statuses within date range
    const totalBookings = await Booking.count({ where: bookingWhere });
    const pendingBookings = await Booking.count({ where: { ...bookingWhere, status: 'pending' } });
    const completedBookings = await Booking.count({ where: { ...bookingWhere, status: 'completed' } });
    const cancelledBookings = await Booking.count({ where: { ...bookingWhere, status: 'cancelled' } });
    const acceptedBookings = await Booking.count({ where: { ...bookingWhere, status: 'accepted' } });

    // Total revenue from completed bookings within date range
    const totalRevenueResult = await Booking.findAll({
      where: { ...bookingWhere, status: 'completed' },
      attributes: [[sequelize.fn('SUM', sequelize.col('total_price')), 'total']],
      raw: true,
    });
    const revenue = parseFloat(totalRevenueResult[0]?.total || 0);

    // Promo codes used count within date range
    const promoCodesUsed = await Booking.count({
      where: {
        ...bookingWhere,
        promo_code: {
          [Op.ne]: null
        }
      }
    });

    const recentOrderField = hasRange ? dateField : 'created_at';
    const recentBookings = await Booking.findAll({
      where: hasRange ? bookingWhere : {},
      include: [
        { model: User, as: 'customer', attributes: ['full_name', 'email'] },
        { model: Service, as: 'service', attributes: ['name'] }
      ],
      order: [[recentOrderField, 'DESC']],
      limit: 5
    });

    const timeframe = (req.query.timeframe || 'day').toLowerCase();
    let trendStartDate = new Date();
    let trendEndDate = new Date();
    trendEndDate.setHours(23, 59, 59, 999);

    if (hasRange) {
      trendStartDate = startDate;
      trendEndDate = endDate;
    } else if (timeframe === 'month') {
      trendStartDate.setMonth(trendStartDate.getMonth() - 12);
    } else if (timeframe === 'year') {
      trendStartDate.setFullYear(trendStartDate.getFullYear() - 5);
    } else {
      trendStartDate.setDate(trendStartDate.getDate() - 30);
    }

    const trendWhere = {
      [dateField]: { [Op.between]: [trendStartDate, trendEndDate] },
      status: { [Op.in]: ['completed', 'accepted', 'pending'] },
    };

    const rawBookings = await Booking.findAll({
      where: trendWhere,
      attributes: [dateField, 'total_price', 'status'],
      order: [[dateField, 'ASC']],
      raw: true
    });

    const bucketMap = new Map();
    const pad = (n) => (n < 10 ? `0${n}` : `${n}`);

    rawBookings.forEach((b) => {
      const d = new Date(b[dateField]);
      let key;
      if (timeframe === 'month') {
        key = `${d.getFullYear()}-${pad(d.getMonth() + 1)}`;
      } else if (timeframe === 'year') {
        key = `${d.getFullYear()}`;
      } else {
        key = d.toISOString().slice(0, 10);
      }

      const cur = bucketMap.get(key) || { count: 0, revenue: 0 };
      cur.count += 1;
      if (b.status === 'completed') {
        cur.revenue += parseFloat(b.total_price || 0);
      }
      bucketMap.set(key, cur);
    });

    // Build trends array sorted by key
    const trends = Array.from(bucketMap.entries())
      .map(([key, val]) => {
        let dateLabel = key;
        if (timeframe === 'month') dateLabel = `${key}-01`;
        if (timeframe === 'year') dateLabel = `${key}-01-01`;
        return { date: dateLabel, count: val.count, revenue: val.revenue.toFixed(2) };
      })
      .sort((a, b) => new Date(a.date) - new Date(b.date));

    sendSuccess(res, {
      stats: {
        totalUsers,
        totalCleaners,
        totalBookings,
        pendingBookings,
        pendingBookingsAllTime: pendingAllTime,
        completedBookings,
        cancelledBookings,
        acceptedBookings,
        totalRevenue: revenue.toFixed(2),
        promoCodesUsed,
      },
      filter: {
        filterMode: hasRange ? (filterMode || 'range') : 'all',
        startDate: hasRange ? startDate.toISOString() : null,
        endDate: hasRange ? endDate.toISOString() : null,
        dateField,
      },
      recentBookings,
      trends
    });
  } catch (error) {
    console.error('Get dashboard error:', error);
    sendError(res, 'Failed to fetch dashboard', 500, error);
  }
};

/**
 * Get all bookings
 */
exports.getAllBookings = async (req, res) => {
  try {
    const { startDate, endDate, hasRange, dateField } = parseDashboardDateRange({
      ...req.query,
      filterMode: req.query.startDate || req.query.endDate || req.query.filterMode === 'today'
        ? (req.query.filterMode || 'range')
        : 'all',
    });

    const where = {};
    if (hasRange) {
      where[dateField] = { [Op.between]: [startDate, endDate] };
    }
    if (req.query.status && req.query.status !== 'all') {
      where.status = req.query.status;
    }

    const bookings = await Booking.findAll({
      where,
      include: [
        {
          model: User,
          as: 'customer',
          attributes: { exclude: ['password'] },
        },
        {
          model: Cleaner,
          as: 'cleaner',
          include: [
            {
              model: User,
              as: 'user',
              attributes: ['full_name', 'email', 'phone']
            }
          ]
        },
        {
          model: Service,
          as: 'service'
        }
      ],
      order: [['created_at', 'DESC']],
    });

    sendSuccess(res, bookings.map(formatBookingRecord));
  } catch (error) {
    console.error('Get bookings error:', error);
    sendError(res, 'Failed to fetch bookings', 500, error);
  }
};

/**
 * Get booking by ID
 */
exports.getBookingById = async (req, res) => {
  try {
    const { id } = req.params;
    const booking = await Booking.findByPk(id, {
      include: [
        {
          model: User,
          as: 'customer',
          attributes: { exclude: ['password'] },
        },
        {
          model: Cleaner,
          as: 'cleaner',
          include: [{ model: User, as: 'user', attributes: ['full_name', 'email', 'phone'] }]
        },
        {
          model: Service,
          as: 'service'
        },
        {
          model: Review,
          as: 'review'
        }
      ]
    });

    if (!booking) {
      return sendError(res, 'Booking not found', 404);
    }

    sendSuccess(res, formatBookingRecord(booking));
  } catch (error) {
    console.error('Get booking detail error:', error);
    sendError(res, 'Failed to fetch booking detail', 500, error);
  }
};

/**
 * Accept Booking
 */
exports.acceptBooking = async (req, res) => {
  const t = await sequelize.transaction();
  try {
    const { id } = req.params;

    const booking = await Booking.findByPk(id, { transaction: t });
    if (!booking) {
      await t.rollback();
      return sendError(res, 'Booking not found', 404);
    }

    booking.status = 'accepted';
    booking.cleaner_id = null;
    await booking.save({ transaction: t });

    // Send notification to customer
    await Notification.create({
      user_id: booking.user_id,
      title: 'Booking Accepted',
      body: `Your booking for ${booking.address} on ${booking.booking_date} has been accepted by the administrator.`,
      is_read: false
    }, { transaction: t });

    await t.commit();
    sendSuccess(res, booking, 'Booking accepted successfully');
  } catch (error) {
    await t.rollback();
    console.error('Accept booking error:', error);
    sendError(res, 'Failed to accept booking', 500, error);
  }
};

/**
 * Cancel Booking
 */
exports.cancelBooking = async (req, res) => {
  const t = await sequelize.transaction();
  try {
    const { id } = req.params;
    const { reason } = req.body;

    const booking = await Booking.findByPk(id, { transaction: t });
    if (!booking) {
      await t.rollback();
      return sendError(res, 'Booking not found', 404);
    }

    booking.status = 'cancelled';
    booking.notes = booking.notes ? `${booking.notes}\n[Admin Cancel: ${reason || 'No reason provided'}]` : `[Admin Cancel: ${reason || 'No reason provided'}]`;
    await booking.save({ transaction: t });

    // Notify customer
    await Notification.create({
      user_id: booking.user_id,
      title: 'Booking Cancelled',
      body: `Your booking at ${booking.address} has been cancelled by the administrator.`,
      is_read: false
    }, { transaction: t });

    // Notify cleaner if assigned
    if (booking.cleaner_id) {
      const cleanerProfile = await Cleaner.findByPk(booking.cleaner_id, { transaction: t });
      if (cleanerProfile) {
        await Notification.create({
          user_id: cleanerProfile.user_id,
          title: 'Assigned Job Cancelled',
          body: `Your assigned job at ${booking.address} has been cancelled by the administrator.`,
          is_read: false
        }, { transaction: t });
      }
    }

    await t.commit();
    sendSuccess(res, booking, 'Booking cancelled successfully');
  } catch (error) {
    await t.rollback();
    console.error('Cancel booking error:', error);
    sendError(res, 'Failed to cancel booking', 500, error);
  }
};

/**
 * Complete Booking
 */
exports.completeBooking = async (req, res) => {
  const t = await sequelize.transaction();
  try {
    const { id } = req.params;

    const booking = await Booking.findByPk(id, { transaction: t });
    if (!booking) {
      await t.rollback();
      return sendError(res, 'Booking not found', 404);
    }

    if (booking.status === 'completed') {
      await t.rollback();
      return sendError(res, 'Booking already completed', 400);
    }

    booking.status = 'completed';
    await booking.save({ transaction: t });

    const { rewardEarned } = await awardCleaningMilestone(booking.user_id, booking, t);

    // Notify Customer
    await Notification.create({
      user_id: booking.user_id,
      title: 'Booking Completed',
      body: rewardEarned
        ? `Your cleaning booking at ${booking.address} is complete. You unlocked a free normal cleaning reward!`
        : `Your cleaning booking at ${booking.address} is complete. Your loyalty circle was filled.`,
      is_read: false
    }, { transaction: t });

    await t.commit();
    sendSuccess(res, booking, 'Booking marked as completed successfully');
  } catch (error) {
    await t.rollback();
    console.error('Complete booking error:', error);
    sendError(res, 'Failed to complete booking', 500, error);
  }
};

/**
 * Get all customers
 */
exports.getAllUsers = async (req, res) => {
  try {
    const users = await User.findAll({
      where: { role: 'customer' },
      attributes: { exclude: ['password'] },
      order: [['created_at', 'DESC']],
    });

    // Compute bookings_count per user
    const usersWithCounts = await Promise.all(users.map(async (u) => {
      const obj = u.toJSON();
      try {
        const count = await Booking.count({ where: { user_id: u.id } });
        obj.bookings_count = count;
      } catch (err) {
        obj.bookings_count = 0;
      }
      return obj;
    }));

    sendSuccess(res, usersWithCounts);
  } catch (error) {
    console.error('Get customers error:', error);
    sendError(res, 'Failed to fetch customers', 500, error);
  }
};

/**
 * Create new customer
 */
exports.createCustomer = async (req, res) => {
  try {
    const { full_name, email, phone, password, loyalty_rewards_available, is_blocked } = req.body;

    if (!full_name || !email || !password) {
      return sendError(res, 'Name, email, and password are required', 400);
    }

    const existing = await User.findOne({ where: { email } });
    if (existing) {
      return sendError(res, 'Email address already exists', 409);
    }

    const hashedPassword = await hashPassword(password);
    const customer = await User.create({
      full_name,
      email,
      phone,
      password: hashedPassword,
      role: 'customer',
      loyalty_rewards_available: parseInt(loyalty_rewards_available, 10) || 0,
      is_blocked: !!is_blocked,
    });

    const payload = customer.toJSON();
    delete payload.password;

    sendSuccess(res, payload, 'Customer created successfully', 201);
  } catch (error) {
    console.error('Create customer error:', error);
    sendError(res, 'Failed to create customer', 500, error);
  }
};

/**
 * Update existing customer details
 */
exports.updateCustomer = async (req, res) => {
  try {
    const { id } = req.params;
    const { full_name, email, phone, password, loyalty_rewards_available, is_blocked } = req.body;

    const user = await User.findByPk(id);
    if (!user || user.role !== 'customer') {
      return sendError(res, 'Customer not found', 404);
    }

    if (full_name !== undefined) user.full_name = full_name;
    if (email !== undefined) user.email = email;
    if (phone !== undefined) user.phone = phone;
    if (password) user.password = await hashPassword(password);
    if (loyalty_rewards_available !== undefined) {
      user.loyalty_rewards_available = parseInt(loyalty_rewards_available, 10) || 0;
    }
    if (is_blocked !== undefined) user.is_blocked = !!is_blocked;

    await user.save();

    const payload = user.toJSON();
    delete payload.password;

    sendSuccess(res, payload, 'Customer updated successfully');
  } catch (error) {
    console.error('Update customer error:', error);
    sendError(res, 'Failed to update customer', 500, error);
  }
};

/**
 * Get customer by ID with full details
 */
exports.getCustomerById = async (req, res) => {
  try {
    const { id } = req.params;
    const customer = await User.findOne({
      where: { id, role: 'customer' },
      attributes: { exclude: ['password'] },
      include: [
        { model: Address, as: 'addresses' },
        {
          model: Booking,
          as: 'bookings',
          include: [{ model: Service, as: 'service', attributes: ['name'] }],
          order: [['created_at', 'DESC']]
        }
      ]
    });

    if (!customer) {
      return sendError(res, 'Customer not found', 404);
    }

    sendSuccess(res, customer);
  } catch (error) {
    console.error('Get customer detail error:', error);
    sendError(res, 'Failed to fetch customer detail', 500, error);
  }
};

/**
 * Block/Unblock Customer
 */
exports.blockCustomer = async (req, res) => {
  try {
    const { id } = req.params;
    const { is_blocked } = req.body;

    const user = await User.findByPk(id);
    if (!user) {
      return sendError(res, 'User not found', 404);
    }

    user.is_blocked = !!is_blocked;
    await user.save();

    sendSuccess(res, { id: user.id, is_blocked: user.is_blocked }, `Customer ${user.is_blocked ? 'blocked' : 'unblocked'} successfully`);
  } catch (error) {
    console.error('Block customer error:', error);
    sendError(res, 'Failed to update customer blocked status', 500, error);
  }
};

/**
 * Delete Customer
 */
exports.deleteCustomer = async (req, res) => {
  const t = await sequelize.transaction();
  try {
    const { id } = req.params;

    const user = await User.findByPk(id, { transaction: t });
    if (!user) {
      await t.rollback();
      return sendError(res, 'Customer not found', 404);
    }

    // Cascade delete notifications and addresses manually if needed, or rely on deletion.
    await Notification.destroy({ where: { user_id: id }, transaction: t });
    await Address.destroy({ where: { user_id: id }, transaction: t });
    
    // Deleting a user with bookings might fail FK constraints depending on database,
    // let's anonymize bookings instead or set customer reference to null, or delete them.
    // In this SQLite/SQL Server schema, setting null or deleting reviews
    await Review.destroy({ where: { user_id: id }, transaction: t });
    
    // We can delete customer's bookings
    await Booking.destroy({ where: { user_id: id }, transaction: t });

    await user.destroy({ transaction: t });

    await t.commit();
    sendSuccess(res, null, 'Customer deleted successfully');
  } catch (error) {
    await t.rollback();
    console.error('Delete customer error:', error);
    sendError(res, 'Failed to delete customer', 500, error);
  }
};

/**
 * Get cleaners (already existing)
 */
exports.getAllCleaners = async (req, res) => {
  try {
    const cleaners = await User.findAll({
      where: { role: 'cleaner' },
      include: [
        {
          model: Cleaner,
          as: 'cleanerProfile',
        },
      ],
      attributes: { exclude: ['password'] },
      order: [['created_at', 'DESC']],
    });

    sendSuccess(res, cleaners);
  } catch (error) {
    console.error('Get cleaners error:', error);
    sendError(res, 'Failed to fetch cleaners', 500, error);
  }
};

/**
 * SERVICES CRUD
 */

exports.getAllServices = async (req, res) => {
  try {
    const services = await Service.findAll({
      order: [['name', 'ASC']],
    });
    sendSuccess(res, services.map(formatServiceRecord));
  } catch (error) {
    console.error('Get services error:', error);
    sendError(res, 'Failed to fetch services', 500, error);
  }
};

exports.createService = async (req, res) => {
  try {
    const { name, description, base_price, duration_hours, image, is_active } = req.body;

    if (!name || !base_price || !duration_hours) {
      return sendError(res, 'Name, base price, and duration are required', 400);
    }

    // Process image: convert empty string to null, trim whitespace
    let imageToSave = null;
    if (image !== undefined && image !== null) {
      const trimmed = image.trim();
      if (trimmed !== '') {
        imageToSave = trimmed;
      }
    }

    const service = await Service.create({
      name,
      description,
      base_price: parseFloat(base_price),
      duration_hours: parseFloat(duration_hours),
      image: imageToSave,
      add_ons: [],
      is_active: is_active !== undefined ? !!is_active : true,
    });

    sendSuccess(res, formatServiceRecord(service), 'Service created successfully', 201);
  } catch (error) {
    console.error('Create service error:', error);
    sendError(res, 'Failed to create service', 500, error);
  }
};

exports.updateService = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description, base_price, duration_hours, image, is_active } = req.body;

    const service = await Service.findByPk(id);
    if (!service) {
      return sendError(res, 'Service not found', 404);
    }

    // Process image: convert empty string to null, trim whitespace
    let imageToSave = service.image; // Keep existing by default
    if (image !== undefined && image !== null) {
      const trimmed = image.trim();
      if (trimmed !== '') {
        imageToSave = trimmed;
      } else {
        imageToSave = null; // Explicitly set to null if empty string
      }
    }

    if (name !== undefined) service.name = name;
    if (description !== undefined) service.description = description;
    if (base_price !== undefined) service.base_price = parseFloat(base_price);
    if (duration_hours !== undefined) service.duration_hours = parseFloat(duration_hours);
    if (image !== undefined) service.image = imageToSave;
    if (is_active !== undefined) service.is_active = !!is_active;

    await service.save();

    sendSuccess(res, formatServiceRecord(service), 'Service updated successfully');
  } catch (error) {
    console.error('Update service error:', error);
    sendError(res, 'Failed to update service', 500, error);
  }
};

exports.deleteService = async (req, res) => {
  try {
    const { id } = req.params;

    const service = await Service.findByPk(id);
    if (!service) {
      return sendError(res, 'Service not found', 404);
    }

    // Checking if service has active bookings to prevent SQL constraint failure
    const activeBookings = await Booking.count({ where: { service_id: id } });
    if (activeBookings > 0) {
      // Soft-deactivate instead
      service.is_active = false;
      await service.save();
      return sendSuccess(res, service, 'Service cannot be deleted because it has booking history. It was automatically deactivated instead.');
    }

    await service.destroy();
    sendSuccess(res, null, 'Service deleted successfully');
  } catch (error) {
    console.error('Delete service error:', error);
    sendError(res, 'Failed to delete service', 500, error);
  }
};

/**
 * Upload Service Image
 */
exports.uploadServiceImage = async (req, res) => {
  try {
    if (!req.file) {
      return sendError(res, 'No image file provided', 400);
    }
    const filename = req.file.filename;
    const imageUrl = resolveServiceImageUrl(filename);
    sendSuccess(res, { filename, image_url: imageUrl }, 'Image uploaded successfully', 201);
  } catch (error) {
    console.error('Upload service image error:', error);
    sendError(res, 'Failed to upload image', 500, error);
  }
};

/**
 * PROMO CODE CRUD
 */

exports.getAllPromos = async (req, res) => {
  try {
    const promos = await PromoCode.findAll({
      order: [['code', 'ASC']],
    });
    sendSuccess(res, promos);
  } catch (error) {
    console.error('Get promos error:', error);
    sendError(res, 'Failed to fetch promos', 500, error);
  }
};

exports.createPromo = async (req, res) => {
  try {
    const { code, type, value, description, conditions, expires_at, is_active, is_hot_offer } = req.body;

    if (!code || !type || value === undefined) {
      return sendError(res, 'Code, type, and value are required', 400);
    }

    const existingPromo = await PromoCode.findOne({ where: { code: code.toUpperCase().trim() } });
    if (existingPromo) {
      return sendError(res, 'Promo code already exists', 400);
    }

    const promo = await PromoCode.create({
      code: code.toUpperCase().trim(),
      type,
      value: parseFloat(value),
      description: description ? description.toString().trim() : null,
      conditions: conditions ? (typeof conditions === 'object' ? JSON.stringify(conditions) : conditions) : null,
      expires_at: expires_at || null,
      is_active: is_active !== undefined ? !!is_active : true,
      is_hot_offer: !!is_hot_offer,
    });

    sendSuccess(res, promo, 'Promo code created successfully', 201);
  } catch (error) {
    console.error('Create promo error:', error);
    sendError(res, 'Failed to create promo code', 500, error);
  }
};

exports.updatePromo = async (req, res) => {
  try {
    const { id } = req.params;
    const { code, type, value, description, conditions, expires_at, is_active } = req.body;

    const promo = await PromoCode.findByPk(id);
    if (!promo) {
      return sendError(res, 'Promo code not found', 404);
    }

    if (code !== undefined) {
      const newCode = code.toUpperCase().trim();
      const existing = await PromoCode.findOne({ where: { code: newCode } });
      if (existing && existing.id !== promo.id) {
        return sendError(res, 'Promo code already exists', 400);
      }
      promo.code = newCode;
    }
    if (type !== undefined) promo.type = type;
    if (value !== undefined) promo.value = parseFloat(value);
    if (description !== undefined) promo.description = description ? description.toString().trim() : null;
    if (conditions !== undefined) promo.conditions = conditions ? (typeof conditions === 'object' ? JSON.stringify(conditions) : conditions) : null;
    if (expires_at !== undefined) promo.expires_at = expires_at || null;
    if (is_active !== undefined) promo.is_active = !!is_active;
    if (req.body.is_hot_offer !== undefined) promo.is_hot_offer = !!req.body.is_hot_offer;

    await promo.save();

    sendSuccess(res, promo, 'Promo code updated successfully');
  } catch (error) {
    console.error('Update promo error:', error);
    sendError(res, 'Failed to update promo code', 500, error);
  }
};

exports.deletePromo = async (req, res) => {
  try {
    const { id } = req.params;

    const promo = await PromoCode.findByPk(id);
    if (!promo) {
      return sendError(res, 'Promo code not found', 404);
    }

    await promo.destroy();
    sendSuccess(res, null, 'Promo code deleted successfully');
  } catch (error) {
    console.error('Delete promo error:', error);
    sendError(res, 'Failed to delete promo code', 500, error);
  }
};

/**
 * CONFIG SETTINGS
 */

exports.getPublicSettings = async (req, res) => {
  try {
    const settings = readSettings();
    sendSuccess(res, {
      supportPhone: settings.supportPhone,
      supportEmail: settings.supportEmail,
      normalHourlyRate: settings.normalHourlyRate,
      deepHourlyRate: settings.deepHourlyRate,
      globalAddOns: Array.isArray(settings.globalAddOns) ? settings.globalAddOns : []
    });
  } catch (error) {
    sendError(res, 'Failed to read public settings', 500, error);
  }
};

exports.getNotificationUnread = async (req, res) => {
  try {
    const lastSeenMs = parseInt(req.query.lastSeen || '0', 10);
    const lastSeen = Number.isFinite(lastSeenMs) ? new Date(lastSeenMs) : new Date(0);

    const unreadCount = await Booking.count({
      where: {
        created_at: { [Op.gt]: lastSeen },
        status: 'pending',
      },
    });

    sendSuccess(res, { unreadCount });
  } catch (error) {
    console.error('Unread notifications error:', error);
    sendError(res, 'Failed to fetch unread notifications', 500, error);
  }
};

exports.getSettings = async (req, res) => {
  try {
    const settings = readSettings();
    sendSuccess(res, settings);
  } catch (error) {
    sendError(res, 'Failed to read business settings', 500, error);
  }
};

exports.updateSettings = async (req, res) => {
  try {
    const {
      businessName,
      supportPhone,
      supportEmail,
      normalHourlyRate,
      deepHourlyRate,
      currency,
      timezone,
      autoConfirmBookings,
      bookingBufferHours
    } = req.body;

    const current = readSettings();
    
    if (businessName !== undefined) current.businessName = businessName;
    if (supportPhone !== undefined) current.supportPhone = supportPhone;
    if (supportEmail !== undefined) current.supportEmail = supportEmail;
    if (normalHourlyRate !== undefined) current.normalHourlyRate = parseFloat(normalHourlyRate);
    if (deepHourlyRate !== undefined) current.deepHourlyRate = parseFloat(deepHourlyRate);
    if (currency !== undefined) current.currency = currency;
    if (timezone !== undefined) current.timezone = timezone;
    if (autoConfirmBookings !== undefined) current.autoConfirmBookings = !!autoConfirmBookings;
    if (bookingBufferHours !== undefined) current.bookingBufferHours = parseInt(bookingBufferHours, 10);
    if (req.body.globalAddOns !== undefined) {
      try {
        current.globalAddOns = Array.isArray(req.body.globalAddOns) ? req.body.globalAddOns : JSON.parse(req.body.globalAddOns);
      } catch (err) {
        current.globalAddOns = [];
      }
    }

    const success = writeSettings(current);
    if (!success) {
      return sendError(res, 'Failed to write settings to disk', 500);
    }

    sendSuccess(res, current, 'Settings updated successfully');
  } catch (error) {
    console.error('Update settings error:', error);
    sendError(res, 'Failed to update settings', 500, error);
  }
};
