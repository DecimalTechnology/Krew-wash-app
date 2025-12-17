class UserModel {
  final String uid;
  final String? email;
  final String? name;
  final int? phone;
  final String? photo;
  final String? buildingId;
  final String? apartmentNumber;
  final bool? isVerified;
  final String? verificationMethod;
  final bool? isDeleted;
  final bool? isActive;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    this.email,
    this.name,
    this.phone,
    this.photo,
    this.buildingId,
    this.apartmentNumber,
    this.isVerified,
    this.verificationMethod,
    this.isDeleted,
    this.isActive,
    required this.role,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromFirebaseUser({
    required String uid,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? photoURL,
    String role = 'user',
  }) {
    return UserModel(
      uid: uid,
      email: email,
      name: displayName,
      phone: phoneNumber != null ? int.tryParse(phoneNumber) : null,
      photo: photoURL,
      buildingId: null,
      apartmentNumber: null,
      isVerified: null,
      verificationMethod: null,
      isDeleted: null,
      isActive: null,
      role: role,
      createdAt: null,
      updatedAt: null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'photo': photo,
      'image': photo, // Also save as 'image' for API compatibility
      'buildingId': buildingId,
      'apartmentNumber': apartmentNumber,
      'isVerified': isVerified,
      'verificationMethod': verificationMethod,
      'isDeleted': isDeleted,
      'isActive': isActive,
      'role': role,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Helper to safely extract String
    String safeString(key) => (map[key] ?? '').toString();
    String? safeStringOrNull(key) {
      final value = map[key];
      if (value == null) return null;
      return value.toString().isEmpty ? null : value.toString();
    }

    // Helper to safely parse phone
    int? safePhone() {
      final value = map['phone'];
      if (value == null) return null;
      if (value is int) return value;
      if (value is String && value.isNotEmpty) {
        return int.tryParse(value);
      }
      return null;
    }

    // Check for both 'image' and 'photo' fields (API uses 'image', model uses 'photo')
    final imageUrl = safeStringOrNull('image') ?? safeStringOrNull('photo');

    return UserModel(
      uid: safeString('_id').isEmpty ? safeString('uid') : safeString('_id'),
      email: safeStringOrNull('email'),
      name: safeStringOrNull('name'),
      phone: safePhone(),
      photo: imageUrl,
      buildingId: safeStringOrNull('buildingId'),
      apartmentNumber: safeStringOrNull('apartmentNumber'),
      isVerified: map['isVerified'] as bool?,
      verificationMethod: safeStringOrNull('verificationMethod'),
      isDeleted: map['isDeleted'] as bool?,
      isActive: map['isActive'] as bool?,
      role: safeString('role').isEmpty ? 'user' : safeString('role'),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString())
          : null,
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    int? phone,
    String? photo,
    String? buildingId,
    String? apartmentNumber,
    bool? isVerified,
    String? verificationMethod,
    bool? isDeleted,
    bool? isActive,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photo: photo ?? this.photo,
      buildingId: buildingId ?? this.buildingId,
      apartmentNumber: apartmentNumber ?? this.apartmentNumber,
      isVerified: isVerified ?? this.isVerified,
      verificationMethod: verificationMethod ?? this.verificationMethod,
      isDeleted: isDeleted ?? this.isDeleted,
      isActive: isActive ?? this.isActive,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, name: $name, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
