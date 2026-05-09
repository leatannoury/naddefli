'use strict';
module.exports = {
  async up(queryInterface, Sequelize) {
    /**
     * Create users table
     */
    await queryInterface.createTable('users', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
      },
      full_name: {
        type: Sequelize.STRING(255),
        allowNull: false,
      },
      email: {
        type: Sequelize.STRING(255),
        allowNull: false,
        unique: true,
      },
      phone: {
        type: Sequelize.STRING(20),
        allowNull: true,
      },
      password: {
        type: Sequelize.STRING(255),
        allowNull: false,
      },
      role: {
        type: Sequelize.ENUM('customer', 'cleaner', 'admin'),
        defaultValue: 'customer',
      },
      created_at: {
        type: Sequelize.DATE,
        defaultValue: Sequelize.NOW,
      },
    });

    /**
     * Create cleaners table
     */
    await queryInterface.createTable('cleaners', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
      },
      user_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'users',
          key: 'id',
        },
      },
      experience_years: {
        type: Sequelize.INTEGER,
        defaultValue: 0,
      },
      rating: {
        type: Sequelize.DECIMAL(3, 2),
        defaultValue: 5.0,
      },
      is_available: {
        type: Sequelize.BOOLEAN,
        defaultValue: true,
      },
      national_id: {
        type: Sequelize.STRING(50),
        allowNull: true,
      },
      created_at: {
        type: Sequelize.DATE,
        defaultValue: Sequelize.NOW,
      },
    });

    /**
     * Create services table
     */
    await queryInterface.createTable('services', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
      },
      name: {
        type: Sequelize.STRING(255),
        allowNull: false,
      },
      description: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      base_price: {
        type: Sequelize.DECIMAL(10, 2),
        allowNull: false,
      },
      duration_hours: {
        type: Sequelize.DECIMAL(5, 2),
        allowNull: false,
      },
      image: {
        type: Sequelize.STRING(255),
        allowNull: true,
      },
      created_at: {
        type: Sequelize.DATE,
        defaultValue: Sequelize.NOW,
      },
    });

    /**
     * Create bookings table
     */
    await queryInterface.createTable('bookings', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
      },
      user_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'users',
          key: 'id',
        },
      },
      cleaner_id: {
        type: Sequelize.UUID,
        allowNull: true,
        references: {
          model: 'cleaners',
          key: 'id',
        },
      },
      service_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'services',
          key: 'id',
        },
      },
      booking_date: {
        type: Sequelize.DATE,
        allowNull: false,
      },
      booking_time: {
        type: Sequelize.STRING(5),
        allowNull: false,
      },
      address: {
        type: Sequelize.TEXT,
        allowNull: false,
      },
      city: {
        type: Sequelize.STRING(100),
        allowNull: false,
      },
      notes: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      total_price: {
        type: Sequelize.DECIMAL(10, 2),
        allowNull: false,
      },
      status: {
        type: Sequelize.ENUM('pending', 'accepted', 'on_the_way', 'started', 'completed', 'cancelled'),
        defaultValue: 'pending',
      },
      is_custom: {
        type: Sequelize.BOOLEAN,
        defaultValue: false,
      },
      property_type: {
        type: Sequelize.STRING(50),
        allowNull: true,
      },
      room_count: {
        type: Sequelize.INTEGER,
        defaultValue: 0,
      },
      bathrooms_count: {
        type: Sequelize.INTEGER,
        defaultValue: 0,
      },
      kitchens_count: {
        type: Sequelize.INTEGER,
        defaultValue: 0,
      },
      cleaning_type: {
        type: Sequelize.STRING(50),
        defaultValue: 'normal',
      },
      extras: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      created_at: {
        type: Sequelize.DATE,
        defaultValue: Sequelize.NOW,
      },
    });

    /**
     * Create reviews table
     */
    await queryInterface.createTable('reviews', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
      },
      booking_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'bookings',
          key: 'id',
        },
      },
      user_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'users',
          key: 'id',
        },
      },
      cleaner_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'cleaners',
          key: 'id',
        },
      },
      rating: {
        type: Sequelize.INTEGER,
        allowNull: false,
      },
      comment: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      created_at: {
        type: Sequelize.DATE,
        defaultValue: Sequelize.NOW,
      },
    });

    /**
     * Create notifications table
     */
    await queryInterface.createTable('notifications', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
      },
      user_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'users',
          key: 'id',
        },
      },
      title: {
        type: Sequelize.STRING(255),
        allowNull: false,
      },
      body: {
        type: Sequelize.TEXT,
        allowNull: false,
      },
      is_read: {
        type: Sequelize.BOOLEAN,
        defaultValue: false,
      },
      created_at: {
        type: Sequelize.DATE,
        defaultValue: Sequelize.NOW,
      },
    });
  },

  async down(queryInterface, Sequelize) {
    /**
     * Drop tables in reverse order of creation
     */
    await queryInterface.dropTable('notifications');
    await queryInterface.dropTable('reviews');
    await queryInterface.dropTable('bookings');
    await queryInterface.dropTable('services');
    await queryInterface.dropTable('cleaners');
    await queryInterface.dropTable('users');
  },
};
