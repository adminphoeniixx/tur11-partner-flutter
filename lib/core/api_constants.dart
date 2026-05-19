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
  static const turfs = '/turfs';
  static String turf(int turfId) => '$turfs/$turfId';
  static String turfUploadMedia(int turfId) => '$turfs/$turfId/upload-media';
  static String turfRemoveMedia(int turfId) => '$turfs/$turfId/remove-media';
  static String turfToggleStatus(int turfId) => '$turfs/$turfId/toggle-status';
  static const slots = '/slots';
  static const generateSlots = '/slots/generate';
  static const blockSlots = '/slots/block';
  static const unblockSlots = '/slots/unblock';
  static const updateSlotPrice = '/slots/update-price';
  static const tournaments = '/tournaments';
  static String tournament(int tournamentId) => '$tournaments/$tournamentId';
  static String tournamentOpenRegistration(int tournamentId) =>
      '${tournament(tournamentId)}/open-registration';
  static String tournamentTeams(int tournamentId) =>
      '${tournament(tournamentId)}/teams';
  static String tournamentGenerateFixtures(int tournamentId) =>
      '${tournament(tournamentId)}/generate-fixtures';
  static String tournamentRecordResult(int tournamentId) =>
      '${tournament(tournamentId)}/record-result';
  static String tournamentComplete(int tournamentId) =>
      '${tournament(tournamentId)}/complete';
  static String tournamentReviews(int tournamentId) =>
      '${tournament(tournamentId)}/reviews';
  static const matches = '/matches';
  static String matchStream(int matchId) => '$matches/$matchId/stream';
  static String matchMuxStream(int matchId) => '$matches/$matchId/stream/mux';
  static String endMatchStream(int matchId) => '$matches/$matchId/stream/end';
  static String matchScoreboard(int matchId) => '$matches/$matchId/scoreboard';
  static String matchCommentary(int matchId) => '$matches/$matchId/commentary';
  static String matchCommentaryEntry(int matchId, int commentaryId) =>
      '$matches/$matchId/commentary/$commentaryId';
  static const profile = '/profile';
  static const fcmToken = '/fcm-token';
  static const bankDetails = '/bank-details';
}
