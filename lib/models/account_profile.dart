class AccountProfile {
  const AccountProfile({
    required this.userKey,
    required this.displayName,
    required this.email,
    required this.phoneNumber,
    required this.shippingAddress,
    required this.avatarUrl,
    required this.bio,
  });

  final String userKey;
  final String displayName;
  final String email;
  final String phoneNumber;
  final String shippingAddress;
  final String avatarUrl;
  final String bio;

  AccountProfile copyWith({
    String? userKey,
    String? displayName,
    String? email,
    String? phoneNumber,
    String? shippingAddress,
    String? avatarUrl,
    String? bio,
  }) {
    return AccountProfile(
      userKey: userKey ?? this.userKey,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userKey': userKey,
      'displayName': displayName,
      'email': email,
      'phoneNumber': phoneNumber,
      'shippingAddress': shippingAddress,
      'avatarUrl': avatarUrl,
      'bio': bio,
    };
  }

  factory AccountProfile.fromJson(Map<String, dynamic> json) {
    return AccountProfile(
      userKey: json['userKey'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      shippingAddress: json['shippingAddress'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
    );
  }
}
