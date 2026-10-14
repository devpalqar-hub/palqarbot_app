/// ================================================================
/// STRIPE CONFIG
/// ================================================================
///
/// Client-side Stripe configuration. Only the publishable key lives
/// here — it's safe to ship in the app. The secret key stays on the
/// backend and is never referenced from Flutter code.
class StripeConfig {
  StripeConfig._();

  static const String publishableKey =
      "pk_test_51SaZdmRqlDwgKVYCe2eLJt1ltFsDlCwHeuVhmCIIpbJYcJ6AK9qsV9sGWveRncWp8P4d0Ycr1nVhryjS2kv72YPW00JRAjEQqj";

  /// Set once we register an Apple Pay merchant ID (Apple Developer
  /// portal + Stripe Dashboard). Left blank until then — the payment
  /// sheet works fine without it, just without the Apple Pay button.
  static const String merchantIdentifier = "";

  /// Shown on the native payment sheet ("Pay {merchantDisplayName}").
  static const String merchantDisplayName = "Villas Qatar";
}
