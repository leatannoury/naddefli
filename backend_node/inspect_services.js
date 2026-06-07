const { Service } = require('./src/models');
const sequelize = require('./src/config/db');

async function main() {
  try {
    await sequelize.authenticate();
    console.log('Database connection OK.');
    const services = await Service.findAll();
    console.log('Services in database:');
    services.forEach(s => {
      console.log(`- ID: ${s.id}\n  Name: ${s.name}\n  Image: "${s.image}"\n  ImageURL: "${s.image_url || 'undefined'}"\n  Active: ${s.is_active}\n  AddOns: ${JSON.stringify(s.add_ons)}`);
    });
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await sequelize.close();
  }
}

main();
