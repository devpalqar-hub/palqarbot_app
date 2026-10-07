
class ApiConstants {
  ApiConstants._();

  static const String baseUrl =
      'https://mybotapi.palqar.com/api';

  static const String login =
      '$baseUrl/auth/login';

  static const String register =
      '$baseUrl/auth/register';

  static const String me =
      '$baseUrl/auth/me';


  static String systemPrompt(String profileId) =>
      '$baseUrl/profiles/$profileId/inbox/system-prompt';

  static const String profiles =
      '$baseUrl/profile';
   static const String addprofiles =
      '$baseUrl/profiles';

  static String profile(String profileId) =>
      '$baseUrl/profiles/$profileId';


  static String whatsapp(String profileId) =>
      '$baseUrl/profiles/$profileId/whatsapp';

  static String instagram(String profileId) =>
      '$baseUrl/profiles/$profileId/instagram';

  static const String myProfiles =
      '$baseUrl/auth/me/profiles';

  static String inboxConversations(String profileId) =>
      '$baseUrl/profiles/$profileId/inbox/conversations';

  static String inboxMessages(String profileId, String conversationId) =>
      '${inboxConversations(profileId)}/$conversationId/messages';

  static String inboxSend(String profileId, String conversationId) =>
      '${inboxConversations(profileId)}/$conversationId/send';

  static String inboxAi(String profileId, String conversationId) =>
      '${inboxConversations(profileId)}/$conversationId/ai';
}
