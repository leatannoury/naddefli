/**
 * NADDEFLI — serviceRecommendationEngine.js
 * Layer: Backend — Utility (AI Rules)
 * Purpose: Deterministic rule engine: quiz answers → cleaning type, hours, price estimate.
 * Connects to: aiController before Gemini call
 */

const fs = require('fs');
const path = require('path');

const SETTINGS_PATH = path.join(__dirname, '../config/settings.json');

const readRates = () => {
  try {
    const settings = JSON.parse(fs.readFileSync(SETTINGS_PATH, 'utf8'));
    return {
      normalHourlyRate: parseFloat(settings.normalHourlyRate) || 4,
      deepHourlyRate: parseFloat(settings.deepHourlyRate) || 6,
    };
  } catch (_) {
    return { normalHourlyRate: 4, deepHourlyRate: 6 };
  }
};

const parseCount = (value, fallback = 1) => {
  if (value === '4+') return 4;
  const parsed = parseInt(value, 10);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
};

const roundHalf = (hours) => Math.max(2, Math.min(12, Math.round(hours * 2) / 2));

const situationLabel = (situation) => {
  const map = {
    regular: 'Regular upkeep',
    deep_needed: 'Needs a deep clean',
    moving_out: 'Moving out',
    post_renovation: 'After renovation',
  };
  return map[situation] || situation;
};

exports.buildRecommendation = (answers = {}) => {
  const {
    propertyType = 'House/Apartment',
    bedrooms = '2',
    bathrooms = '1',
    kitchens = '1',
    situation = 'regular',
    pets = 'no',
  } = answers;

  const bedroomCount = parseCount(bedrooms, 2);
  const bathroomCount = parseCount(bathrooms, 1);
  const kitchenCount = parseCount(kitchens, 1);

  let durationHours = 2;
  durationHours += bedroomCount * 0.75;
  durationHours += bathroomCount * 0.5;
  durationHours += kitchenCount * 0.25;

  if (propertyType === 'Office') durationHours *= 0.85;
  if (propertyType === 'Villa') durationHours *= 1.2;

  if (situation === 'moving_out') durationHours += 1.5;
  if (situation === 'post_renovation') durationHours += 2;
  if (situation === 'deep_needed') durationHours += 1;
  if (pets === 'yes') durationHours += 0.5;

  let cleaningType = 'normal';
  if (['moving_out', 'post_renovation', 'deep_needed'].includes(situation)) {
    cleaningType = 'deep';
  }
  if (bedroomCount >= 4 || bathroomCount >= 3) {
    cleaningType = 'deep';
  }

  durationHours = roundHalf(durationHours);

  const rates = readRates();
  const hourlyRate = cleaningType === 'deep' ? rates.deepHourlyRate : rates.normalHourlyRate;
  const estimatedPrice = Math.round(hourlyRate * durationHours * 100) / 100;

  const cleaningLabel = cleaningType === 'deep' ? 'Deep Cleaning' : 'Normal Cleaning';

  return {
    cleaningType,
    cleaningLabel,
    durationHours,
    estimatedPrice,
    hourlyRate,
    propertyType,
    bedrooms: bedroomCount,
    bathrooms: bathroomCount,
    kitchens: kitchenCount,
    situation,
    pets,
    summary: `Based on your ${bedroomCount}-bedroom ${propertyType.toLowerCase()} with ${situationLabel(situation).toLowerCase()}, we recommend ${cleaningLabel.toLowerCase()} for about ${durationHours} hours.`,
    reasons: [
      `${bedroomCount} bedroom(s), ${bathroomCount} bathroom(s), ${kitchenCount} kitchen(s)`,
      situationLabel(situation),
      pets === 'yes' ? 'Pet-friendly home considered' : 'Standard home setup',
    ],
  };
};
