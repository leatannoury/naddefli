// Use 192.168.1.107 for your physical device (Infinix X6827)
const String BASE_URL = 'http://192.168.1.107:5000/api';
const String API_ORIGIN = 'http://192.168.1.107:5000';

class ApiEndpoints {
  static const String baseOrigin = API_ORIGIN;
  // Auth
  static const String register = '$BASE_URL/auth/register';
  static const String login = '$BASE_URL/auth/login';
  static const String profile = '$BASE_URL/auth/profile';

  // Services
  static const String services = '$BASE_URL/services';
  static String serviceDetail(String id) => '$BASE_URL/services/$id';

  // Bookings
  static const String createBooking = '$BASE_URL/bookings/create';
  static const String myBookings = '$BASE_URL/bookings/my-bookings';
  static String bookingDetail(String id) => '$BASE_URL/bookings/$id';
  static String cancelBooking(String id) => '$BASE_URL/bookings/cancel/$id';

  // Notifications
  static const String notifications = '$BASE_URL/notifications';
  static String markAsRead(String id) => '$BASE_URL/notifications/$id/read';
  static const String markAllAsRead = '$BASE_URL/notifications/read-all';

  // Cleaner
  static const String cleanerJobs = '$BASE_URL/cleaner/jobs';
  static String acceptBooking(String id) => '$BASE_URL/cleaner/accept/$id';
  static String updateStatus(String id) => '$BASE_URL/cleaner/status/$id';
  static const String earnings = '$BASE_URL/cleaner/earnings';
  static const String availability = '$BASE_URL/cleaner/availability';

  // Reviews
  static const String createReview = '$BASE_URL/reviews/create';
  static String cleanerReviews(String cleanerId) =>
      '$BASE_URL/reviews/cleaner/$cleanerId';

  // Addresses
  static const String addresses = '$BASE_URL/addresses';
  static String deleteAddress(String id) => '$BASE_URL/addresses/$id';
  static String updateAddress(String id) => '$BASE_URL/addresses/$id';

  // Promo Code Validation
  static const String validatePromo = '$BASE_URL/promo/validate';

  // Complete Booking
  static String completeBooking(String id) => '$BASE_URL/bookings/complete/$id';
}
