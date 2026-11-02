/// Credentials for the Apple App Review team.
/// Signing in with this personal number, expiry, block, and phone
/// skips OTP. Every other account still uses the live login flow.
class StoreReviewAccount {
  const StoreReviewAccount._();

  static const String cpr = '900112233';
  static const String expiry = '31/12/2030';
  static const String block = '412';
  static const String phone = '33001122';
  static const String userId = 'store-review';

  static bool isReviewUser(String? userId) {
    return userId?.trim() == StoreReviewAccount.userId;
  }

  static bool matches({
    required String cpr,
    required String expiry,
    required String block,
    required String phone,
  }) {
    return cpr.trim() == StoreReviewAccount.cpr &&
        expiry.trim() == StoreReviewAccount.expiry &&
        block.trim() == StoreReviewAccount.block &&
        phone.trim() == StoreReviewAccount.phone;
  }
}
