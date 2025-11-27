class StaffModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String status;
  final int totalTasksCompleted;
  final bool isActive;
  final String cleanerId;
  final String? createdAt;
  final String? updatedAt;
  final String role; // Always 'staff' for cleaners

  StaffModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.status,
    required this.totalTasksCompleted,
    required this.isActive,
    required this.cleanerId,
    this.createdAt,
    this.updatedAt,
    this.role = 'staff',
  });

  factory StaffModel.fromMap(Map<String, dynamic> map) {
    return StaffModel(
      id: map['_id'] ?? map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      status: map['status'] ?? 'Available',
      totalTasksCompleted: map['totalTasksCompleted'] ?? 0,
      isActive: map['isActive'] ?? true,
      cleanerId: map['cleanerId'] ?? '',
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      role: 'staff',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'status': status,
      'totalTasksCompleted': totalTasksCompleted,
      'isActive': isActive,
      'cleanerId': cleanerId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'role': role,
    };
  }

  StaffModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? status,
    int? totalTasksCompleted,
    bool? isActive,
    String? cleanerId,
    String? createdAt,
    String? updatedAt,
    String? role,
  }) {
    return StaffModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      status: status ?? this.status,
      totalTasksCompleted: totalTasksCompleted ?? this.totalTasksCompleted,
      isActive: isActive ?? this.isActive,
      cleanerId: cleanerId ?? this.cleanerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      role: role ?? this.role,
    );
  }

  @override
  String toString() {
    return 'StaffModel(id: $id, name: $name, cleanerId: $cleanerId, email: $email)';
  }
}
