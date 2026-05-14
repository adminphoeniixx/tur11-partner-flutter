class ApiConstants {
  static const String baseUrl =
      'https://ai-turf11-laravel.rmsiry.easypanel.host/api/v1/owner';

  static const sendOtp = '/auth/send-otp';
  static const verifyOtp = '/auth/verify-otp';
  static const resendOtp = sendOtp;
  static const login = verifyOtp;
  static const register = '/auth/register';
  static const logout = '/auth/logout';
  static const dashboard = '/dashboard';
  static const occupancy = '/occupancy';
  static const bookings = '/bookings';
  static const cancellations = '/cancellations';
  static const payoutSummary = '/payout-summary';
  static const payouts = '/payouts';
  static const reviews = '/reviews';
  static const matches = '/matches';
  static const profile = '/profile';
  static const fcmToken = '/fcm-token';
  static const bankDetails = '/bank-details';
}
