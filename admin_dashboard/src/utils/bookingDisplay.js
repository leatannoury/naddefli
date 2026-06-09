/**
 * NADDEFLI — bookingDisplay.js
 * Layer: Admin — Utility
 * Purpose: Formats booking title: shows "Custom Cleaning (Deep)" vs service name correctly.
 * Connects to: Bookings page, BookingDetails
 */

export const getBookingServiceLabel = (booking) => {
  if (!booking) return 'Cleaning Service';

  if (booking.display_service_name) {
    return booking.display_service_name;
  }

  const isCustom =
    booking.is_custom === true ||
    booking.is_custom === 1 ||
    booking.is_custom === 'true';

  if (isCustom) {
    const type =
      String(booking.cleaning_type || 'normal').toLowerCase() === 'deep'
        ? 'Deep'
        : 'Normal';
    return `Custom Cleaning (${type})`;
  }

  return booking.service?.name || booking.service_name || 'Cleaning Service';
};
