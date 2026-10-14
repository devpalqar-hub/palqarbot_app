class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String authProvider;
  final bool isProfileComplete;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.authProvider,
    required this.isProfileComplete,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      role: json["role"] ?? "",
      authProvider: json["authProvider"] ?? "",
      isProfileComplete: json["isProfileComplete"] ?? false,
      isActive: json["isActive"] ?? false,
      // Some responses (e.g. the "profile" object embedded in social
      // login responses) omit createdAt/updatedAt entirely - don't let
      // a missing/unparsable date blow up the whole profile and leave
      // the UI stuck showing "Guest".
      createdAt: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? "") ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "phone": phone,
      };
}