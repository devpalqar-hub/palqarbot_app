class ApiEndpoints {
  ApiEndpoints._();

  // OTP
  static const String sendOtp = "/api/auth/otp/send";

  static const String verifyOtp = "/api/auth/otp/verify";

  // Social login
  static const String googleAuth = "/api/auth/google";
  static const String appleAuth = "/api/auth/apple";

  // Email/password login (dealer portal)
  static const String login = "/api/auth/login";

  // Profile
  static const String completeProfile = "/api/auth/complete-profile";

  static const String authMe = "/api/auth/me";

  static const String mypropertyList = "/api/listings/my";

  static const String propertyList = "/api/listings";

  static const String propertyAdd = "/api/listings";

  static const String listingOptions = "/api/listings/options";

  static const String chatConversations = "/api/chat/conversations";

  static const String wishlists = "/api/wishlists";

  static String wishlistByProperty(String propertyId) {
    return "/api/wishlists/$propertyId";
  }

  static String scheduleVisit(String propertyId) {
    return "/api/visits/$propertyId";
  }

  static String acceptVisit(String visitId) {
    return "/api/visits/$visitId/accept";
  }

  static const String visitsAsOwner = "/api/visits/as-owner";

  static const String visitsAsVisitor = "/api/visits/as-visitor";

  static String propertyBySlug(String slug) {
    return "/api/listings/slug/"
        "${Uri.encodeComponent(slug)}";
  }

  static const String featuredPlans = "/api/featured-plans";
  static const String featuredProperties = "/api/featured";
  static const String myfeaturedProperties = "/api/featured/my";
  static const String featuredCheckout = "/api/featured/checkout";
  static String markPropertyAsSold(String propertyId) {
    return "/api/listings/$propertyId/sold";
  }

  /// PENDING_PAYMENT -> live activation gate.
  ///
  /// If free quota is available, activates the listing immediately
  /// (`activated: true`); otherwise returns a Stripe Checkout Session
  /// (`price`, `stripeSessionId`, `paymentUrl`, `paymentIntentClientSecret`).
  /// Same mechanics as [featuredCheckout].
  static const String makeListingPayment = "/api/listings/make-payment";

  static String closeVisit(String visitId) => "/api/visits/$visitId/close";
  static const String myfeaturedPlans = '/api/featured-plans';

  static const String supportTickets = "/api/support/tickets";
  static const String estimatePrice = "/api/listings/estimate-price";

  static const String banners = "/api/banners";

  static const String geocode = "/api/listings/geocode";
  static const String reverseGeocode = "/api/listings/reverse-geocode";

  static String searchAutocomplete(String query) {
    return "/api/search/autocomplete?q=${Uri.encodeComponent(query)}";
  }
  static String myProfile = "/api/users/profile/me";
  static String userById(String id) => "/api/users/$id";
  static const String dealers = "/api/dealers";
  static String dealerDetails(String dealerId) {
    return "/api/dealers/$dealerId";
  }
  static const String nearbyProperties = "/api/listings/nearby";
  static const String verifyPhoneCheck = "/api/listings/verify-phone/check";
  static const String verifyPhoneSendOtp = "/api/listings/verify-phone/send-otp";
  static const String verifyPhoneVerifyOtp =  "/api/listings/verify-phone/verify-otp";
  static const String fcmToken = "/api/users/fcm-token";

  static const String invoices = "/api/invoices";

  static String invoiceDetail(String id) {
    return "/api/invoices/$id";
  }

  static String listingWhatsappClick(String listingId) {
    return "/api/listings/$listingId/track/whatsapp-click";
  }

  // Dealer portal
  static const String dealerAnalyticsDashboard =
      "/api/dealers/analytics/dashboard";
  static const String dealerSubscriptionsMy = "/api/dealer-subscriptions/my";

}
