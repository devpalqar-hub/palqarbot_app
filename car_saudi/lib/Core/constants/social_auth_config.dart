/// Config for "Sign in with Apple" on Android.
///
/// Apple only has a native SDK on iOS - on Android the plugin falls back
/// to a web OAuth flow, which needs a Services ID (acts as the OAuth
/// client id) and a return URL registered in the Apple Developer portal.
/// Both are still placeholders; see the setup steps below.
///
/// Setup (Apple Developer portal, https://developer.apple.com/account):
///   1. Certificates, Identifiers & Profiles -> Identifiers -> "+"
///      -> Services IDs. Create one, e.g. "com.villasqatar.app.signin".
///      Enable "Sign in with Apple", configure it, and add:
///        - Domain: apivillas.palqar.cloud
///        - Return URL: https://apivillas.palqar.cloud/api/auth/apple/callback
///      (the domain must serve an apple-developer-domain-association
///      file, and the return URL must be a real backend endpoint that
///      receives Apple's POST and redirects into the app - that route
///      needs to be added on the backend, it's not part of this repo).
///   2. Put the Services ID identifier below as [appleServiceId].
///   3. Put the exact return URL below as [appleRedirectUri].
class SocialAuthConfig {
  SocialAuthConfig._();

  /// TODO: replace with the Services ID created in the Apple Developer
  /// portal (step 1 above). Apple Sign-In on Android will fail until
  /// this is a real, registered value.
  static const String appleServiceId = 'com.villasqatar.app.signin';

  /// TODO: replace with the backend callback route registered as the
  /// Services ID's "Return URL" (step 1 above).
  static const String appleRedirectUri =
      'https://apivillas.palqar.cloud/api/auth/apple/callback';
}
