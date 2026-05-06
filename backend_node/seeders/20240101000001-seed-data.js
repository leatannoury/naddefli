'use strict';
const { hashPassword } = require('../src/utils/helpers');

module.exports = {
  async up(queryInterface, Sequelize) {
    // Create sample services
    const services = [
      {
        id: '11111111-1111-1111-1111-111111111111',
        name: 'Kitchen Cleaning',
        description: 'Professional kitchen cleaning service including appliances and deep clean',
        base_price: 15.00,
        duration_hours: 2.00,
        image: 'kitchen.jpg',
        created_at: new Date(),
      },
      {
        id: '22222222-2222-2222-2222-222222222222',
        name: 'Bathroom Cleaning',
        description: 'Thorough bathroom cleaning service',
        base_price: 10.00,
        duration_hours: 1.00,
        image: 'bathroom.jpg',
        created_at: new Date(),
      },
      {
        id: '33333333-3333-3333-3333-333333333333',
        name: 'Bedroom Cleaning',
        description: 'Bedroom and living area cleaning service',
        base_price: 12.00,
        duration_hours: 1.5,
        image: 'bedroom.jpg',
        created_at: new Date(),
      },
      {
        id: '44444444-4444-4444-4444-444444444444',
        name: 'Full House Cleaning',
        description: 'Complete house cleaning service',
        base_price: 40.00,
        duration_hours: 4.00,
        image: 'fullhouse.jpg',
        created_at: new Date(),
      },
      {
        id: '55555555-5555-5555-5555-555555555555',
        name: 'Window Cleaning',
        description: 'Professional window cleaning service',
        base_price: 20.00,
        duration_hours: 1.5,
        image: 'windows.jpg',
        created_at: new Date(),
      },
      {
        id: '66666666-6666-6666-6666-666666666666',
        name: 'Sofa Cleaning',
        description: 'Deep clean sofa and furniture',
        base_price: 25.00,
        duration_hours: 2.00,
        image: 'sofa.jpg',
        created_at: new Date(),
      },
      {
        id: '77777777-7777-7777-7777-777777777777',
        name: 'Pest Control',
        description: 'Professional pest control service',
        base_price: 50.00,
        duration_hours: 2.00,
        image: 'pest.jpg',
        created_at: new Date(),
      },
      {
        id: '88888888-8888-8888-8888-888888888888',
        name: 'Office Cleaning',
        description: 'Commercial office cleaning service',
        base_price: 35.00,
        duration_hours: 3.00,
        image: 'office.jpg',
        created_at: new Date(),
      },
    ];

    await queryInterface.bulkInsert('services', services);

    // Create sample users
    const adminPassword = await hashPassword('123456');
    const userPassword = await hashPassword('123456');
    const cleanerPassword = await hashPassword('123456');

    const users = [
      {
        id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        full_name: 'Admin User',
        email: 'admin@test.com',
        phone: '+1234567890',
        password: adminPassword,
        role: 'admin',
        created_at: new Date(),
      },
      {
        id: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
        full_name: 'Test Customer',
        email: 'user@test.com',
        phone: '+1234567891',
        password: userPassword,
        role: 'customer',
        created_at: new Date(),
      },
      {
        id: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
        full_name: 'Test Cleaner',
        email: 'cleaner@test.com',
        phone: '+1234567892',
        password: cleanerPassword,
        role: 'cleaner',
        created_at: new Date(),
      },
    ];

    await queryInterface.bulkInsert('users', users);

    // Create cleaner profile for test cleaner
    await queryInterface.bulkInsert('cleaners', [
      {
        id: 'dddddddd-dddd-dddd-dddd-dddddddddddd',
        user_id: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
        experience_years: 5,
        rating: 4.8,
        is_available: true,
        national_id: 'ID123456',
        created_at: new Date(),
      },
    ]);
  },

  async down(queryInterface, Sequelize) {
    // Delete seeders data
    await queryInterface.bulkDelete('cleaners', null, {});
    await queryInterface.bulkDelete('users', null, {});
    await queryInterface.bulkDelete('services', null, {});
  },
};
