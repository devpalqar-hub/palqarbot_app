class DealerListModel {
  final List<Dealer> data;
  final Meta meta;

  DealerListModel({
    required this.data,
    required this.meta,
  });

  factory DealerListModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DealerListModel(
      data: (json["data"] as List? ?? [])
          .map((e) => Dealer.fromJson(e))
          .toList(),
      meta: Meta.fromJson(json["meta"] ?? {}),
    );
  }
}

class Dealer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final bool isActive;
  final DateTime createdAt;
  final DealerProfile dealerProfile;
  final bool hasActiveSubscription;

  Dealer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.isActive,
    required this.createdAt,
    required this.dealerProfile,
    required this.hasActiveSubscription,
  });

  factory Dealer.fromJson(
    Map<String, dynamic> json,
  ) {
    return Dealer(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      isActive: json["isActive"] ?? false,
      createdAt: DateTime.parse(
        json["createdAt"],
      ),
      dealerProfile: DealerProfile.fromJson(
        json["dealerProfile"] ?? {},
      ),
      hasActiveSubscription:
          json["hasActiveSubscription"] ?? false,
    );
  }
}

class DealerProfile {
  final String id;
  final String userId;
  final String dealerName;
  final String contactPhone;
  final String? tagline;
  final String coverImage;
  final String tradeNumber;
  final String reraNumber;
  final String address;
  final String city;
  final String country;
  final String website;
  final String description;
  final String? facebook;
  final String? youtube;
  final String? whatsapp;
  final String? instagram;

  DealerProfile({
    required this.id,
    required this.userId,
    required this.dealerName,
    required this.contactPhone,
    this.tagline,
    required this.coverImage,
    required this.tradeNumber,
    required this.reraNumber,
    required this.address,
    required this.city,
    required this.country,
    required this.website,
    required this.description,
    this.facebook,
    this.youtube,
    this.whatsapp,
    this.instagram,
  });

  factory DealerProfile.fromJson(
    Map<String, dynamic> json,
  ) {
    return DealerProfile(
      id: json["id"] ?? "",
      userId: json["userId"] ?? "",
      dealerName: json["dealerName"] ?? "",
      contactPhone: json["contactPhone"] ?? "",
      tagline: json["tagline"],
      coverImage: json["coverImage"] ?? "",
      tradeNumber: json["tradeNumber"] ?? "",
      reraNumber: json["reraNumber"] ?? "",
      address: json["address"] ?? "",
      city: json["city"] ?? "",
      country: json["country"] ?? "",
      website: json["website"] ?? "",
      description: json["description"] ?? "",
      facebook: json["facebook"],
      youtube: json["youtube"],
      whatsapp: json["whatsapp"],
      instagram: json["instagram"],
    );
  }
}

class Meta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  Meta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory Meta.fromJson(
    Map<String, dynamic> json,
  ) {
    return Meta(
      total: json["total"] ?? 0,
      page: json["page"] ?? 1,
      limit: json["limit"] ?? 10,
      totalPages: json["totalPages"] ?? 1,
    );
  }
}