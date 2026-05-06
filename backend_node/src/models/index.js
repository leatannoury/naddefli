const User = require('./User');
const Cleaner = require('./Cleaner');
const Service = require('./Service');
const Booking = require('./Booking');
const Review = require('./Review');
const Notification = require('./Notification');

/**
 * Define model associations
 */
const initializeAssociations = () => {
  // User to Cleaner (one-to-one)
  User.hasOne(Cleaner, { foreignKey: 'user_id', as: 'cleanerProfile' });
  Cleaner.belongsTo(User, { foreignKey: 'user_id', as: 'user' });

  // User to Booking (one-to-many)
  User.hasMany(Booking, { foreignKey: 'user_id', as: 'bookings' });
  Booking.belongsTo(User, { foreignKey: 'user_id', as: 'customer' });

  // Cleaner to Booking (one-to-many)
  Cleaner.hasMany(Booking, { foreignKey: 'cleaner_id', as: 'assignedBookings' });
  Booking.belongsTo(Cleaner, { foreignKey: 'cleaner_id', as: 'cleaner' });

  // Service to Booking (one-to-many)
  Service.hasMany(Booking, { foreignKey: 'service_id', as: 'bookings' });
  Booking.belongsTo(Service, { foreignKey: 'service_id', as: 'service' });

  // Booking to Review (one-to-many)
  Booking.hasOne(Review, { foreignKey: 'booking_id', as: 'review' });
  Review.belongsTo(Booking, { foreignKey: 'booking_id', as: 'booking' });

  // User to Review (one-to-many)
  User.hasMany(Review, { foreignKey: 'user_id', as: 'givenReviews' });
  Review.belongsTo(User, { foreignKey: 'user_id', as: 'reviewer' });

  // Cleaner to Review (one-to-many)
  Cleaner.hasMany(Review, { foreignKey: 'cleaner_id', as: 'receivedReviews' });
  Review.belongsTo(Cleaner, { foreignKey: 'cleaner_id', as: 'reviewedCleaner' });

  // User to Notification (one-to-many)
  User.hasMany(Notification, { foreignKey: 'user_id', as: 'notifications' });
  Notification.belongsTo(User, { foreignKey: 'user_id', as: 'user' });
};

module.exports = {
  User,
  Cleaner,
  Service,
  Booking,
  Review,
  Notification,
  initializeAssociations,
};
