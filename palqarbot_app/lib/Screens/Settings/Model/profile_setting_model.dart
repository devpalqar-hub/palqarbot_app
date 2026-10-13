class ProfileSettingsModel {
  final String id;
  final String email;
  final String role;
  final String firstName;
  final String lastName;
  final bool isActive;
  final String? lastLoginAt;
  final String? createdAt;
  final List<UserProfileModel> userProfiles;

  ProfileSettingsModel({
    required this.id,
    required this.email,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.isActive,
    this.lastLoginAt,
    this.createdAt,
    required this.userProfiles,
  });

  factory ProfileSettingsModel.fromJson(Map<String, dynamic> json) {
    return ProfileSettingsModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      isActive: json['isActive'] == true,
      lastLoginAt: json['lastLoginAt']?.toString(),
      createdAt: json['createdAt']?.toString(),
      userProfiles:
          (json['userProfiles'] as List<dynamic>?)
              ?.whereType<Map>()
              .map(
                (item) =>
                    UserProfileModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList() ??
          [],
    );
  }
}

// ============================================================
// USER PROFILE
// ============================================================

class UserProfileModel {
  final bool isOwner;
  final ProfileModel profile;

  UserProfileModel({required this.isOwner, required this.profile});

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final profileJson = json['profile'];

    return UserProfileModel(
      isOwner: json['isOwner'] == true,
      profile: ProfileModel.fromJson(
        profileJson is Map
            ? Map<String, dynamic>.from(profileJson)
            : <String, dynamic>{},
      ),
    );
  }
}

// ============================================================
// PROFILE
// ============================================================

class ProfileModel {
  final String id;
  final String name;
  final String slug;
  final String systemPrompt;
  final bool autoReplyEnabled;
  final String? createdAt;
  final String? whatsappProvider;

  final WhatsAppConfigModel? whatsappConfig;
  final OpenWaConfigModel? openWaConfig;
  final InstagramConfigModel? instagramConfig;

  ProfileModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.systemPrompt,
    required this.autoReplyEnabled,
    this.createdAt,
    this.whatsappProvider,
    this.whatsappConfig,
    this.openWaConfig,
    this.instagramConfig,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      systemPrompt: json['systemPrompt']?.toString() ?? '',
      autoReplyEnabled: json['autoReplyEnabled'] == true,
      createdAt: json['createdAt']?.toString(),
      whatsappProvider: json['whatsappProvider']?.toString(),

      whatsappConfig: json['whatsappConfig'] is Map
          ? WhatsAppConfigModel.fromJson(
              Map<String, dynamic>.from(json['whatsappConfig']),
            )
          : null,

      openWaConfig: json['openWaConfig'] is Map
          ? OpenWaConfigModel.fromJson(
              Map<String, dynamic>.from(json['openWaConfig']),
            )
          : null,

      instagramConfig: json['instagramConfig'] is Map
          ? InstagramConfigModel.fromJson(
              Map<String, dynamic>.from(json['instagramConfig']),
            )
          : null,
    );
  }
}

// ============================================================
// WHATSAPP CONFIG
// ============================================================

class WhatsAppConfigModel {
  final String? id;
  final String phoneNumberId;
  final String businessAccountId;
  final bool enabled;

  WhatsAppConfigModel({
    this.id,
    required this.phoneNumberId,
    required this.businessAccountId,
    required this.enabled,
  });

  factory WhatsAppConfigModel.fromJson(Map<String, dynamic> json) {
    return WhatsAppConfigModel(
      id: json['id']?.toString(),
      phoneNumberId: json['phoneNumberId']?.toString() ?? '',
      businessAccountId: json['businessAccountId']?.toString() ?? '',
      enabled: json['enabled'] == true,
    );
  }
}

// ============================================================
// OPEN WA CONFIG
// ============================================================

class OpenWaConfigModel {
  final String? sessionStatus;
  final String? connectedNumber;
  final bool enabled;

  OpenWaConfigModel({
    this.sessionStatus,
    this.connectedNumber,
    required this.enabled,
  });

  factory OpenWaConfigModel.fromJson(Map<String, dynamic> json) {
    return OpenWaConfigModel(
      sessionStatus: json['sessionStatus']?.toString(),
      connectedNumber: json['connectedNumber']?.toString(),
      enabled: json['enabled'] == true,
    );
  }
}

// ============================================================
// INSTAGRAM CONFIG
// ============================================================

class InstagramConfigModel {
  final String? id;
  final String accountId;
  final bool enabled;

  InstagramConfigModel({
    this.id,
    required this.accountId,
    required this.enabled,
  });

  factory InstagramConfigModel.fromJson(Map<String, dynamic> json) {
    return InstagramConfigModel(
      id: json['id']?.toString(),
      accountId: json['accountId']?.toString() ?? '',
      enabled: json['enabled'] == true,
    );
  }
}
