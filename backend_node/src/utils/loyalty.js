/**
 * NADDEFLI — loyalty.js
 * Layer: Backend — Utility
 * Purpose: Awards loyalty milestones: every 4 completed bookings → 1 free reward.
 * Connects to: Called when booking marked completed
 */

const { User } = require('../models');

const awardCleaningMilestone = async (userId, booking, transaction) => {
  const user = await User.findByPk(userId, { transaction });
  if (!user) return { rewardEarned: false };

  const nextProgress = (user.loyalty_progress || 0) + 1;
  const rewardEarned = nextProgress >= 4;

  user.completed_bookings_count = (user.completed_bookings_count || 0) + 1;
  user.loyalty_progress = rewardEarned ? nextProgress - 4 : nextProgress;
  if (rewardEarned) {
    user.loyalty_rewards_available = (user.loyalty_rewards_available || 0) + 1;
    booking.loyalty_reward_earned = true;
  }

  await user.save({ transaction });
  await booking.save({ transaction });
  return { rewardEarned };
};

module.exports = { awardCleaningMilestone };
