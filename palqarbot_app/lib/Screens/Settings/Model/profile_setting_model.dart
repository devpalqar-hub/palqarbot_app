
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

  factory ProfileSettingsModel.fromJson(
    Map<String, dynamic> json,
  ) {
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
                  ?.map(
                    (item) => UserProfileModel.fromJson(
                      Map<String, dynamic>.from(item),
                    ),
                  )
                  .toList() ??
              [],
    );
  }
}

class UserProfileModel {
  final bool isOwner;
  final ProfileModel profile;

  UserProfileModel({
    required this.isOwner,
    required this.profile,
  });

  factory UserProfileModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserProfileModel(
      isOwner: json['isOwner'] == true,
      profile: ProfileModel.fromJson(
        Map<String, dynamic>.from(
          json['profile'] ?? {},
        ),
      ),
    );
  }
}

class ProfileModel {
  final String id;
  final String name;
  final String slug;
  final String systemPrompt;
  final bool autoReplyEnabled;
  final WhatsAppConfigModel? whatsappConfig;
  final InstagramConfigModel? instagramConfig;

  ProfileModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.systemPrompt,
    required this.autoReplyEnabled,
    this.whatsappConfig,
    this.instagramConfig,
  });

  factory ProfileModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProfileModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      systemPrompt:
          json['systemPrompt']?.toString() ?? '',
      autoReplyEnabled:
          json['autoReplyEnabled'] == true,

      whatsappConfig:
          json['whatsappConfig'] is Map
              ? WhatsAppConfigModel.fromJson(
                  Map<String, dynamic>.from(
                    json['whatsappConfig'],
                  ),
                )
              : null,

      instagramConfig:
          json['instagramConfig'] is Map
              ? InstagramConfigModel.fromJson(
                  Map<String, dynamic>.from(
                    json['instagramConfig'],
                  ),
                )
              : null,
    );
  }
}

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

  factory WhatsAppConfigModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return WhatsAppConfigModel(
      id: json['id']?.toString(),
      phoneNumberId:
          json['phoneNumberId']?.toString() ?? '',
      businessAccountId:
          json['businessAccountId']?.toString() ?? '',
      enabled: json['enabled'] == true,
    );
  }
}

class InstagramConfigModel {
  final String? id;
  final String accountId;
  final bool enabled;

  InstagramConfigModel({
    this.id,
    required this.accountId,
    required this.enabled,
  });

  factory InstagramConfigModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return InstagramConfigModel(
      id: json['id']?.toString(),
      accountId:
          json['accountId']?.toString() ?? '',
      enabled: json['enabled'] == true,
    );
  }
}