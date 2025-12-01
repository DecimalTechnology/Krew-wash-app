import 'package:flutter/foundation.dart';

class CleanerBooking {
  CleanerBooking({
    required this.id,
    required this.bookingId,
    required this.status,
    required this.bookingType,
    required this.cleanersAssigned,
    required this.addons,
    this.payment,
    this.user,
    this.package,
    this.vehicleId,
    this.buildingId,
    this.buildingInfo,
    this.totalPrice,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String bookingId;
  final String status;
  final String bookingType;
  final List<String> cleanersAssigned;
  final List<BookingAddon> addons;
  final BookingPayment? payment;
  final BookingUser? user;
  final BookingPackage? package;
  final String? vehicleId;
  final String? buildingId;
  final BuildingInfo? buildingInfo;
  final double? totalPrice;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory CleanerBooking.fromMap(Map<String, dynamic> map) {
    return CleanerBooking(
      id: map['_id']?.toString() ?? '',
      bookingId: map['bookingId']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      bookingType: map['bookingType']?.toString() ?? '',
      cleanersAssigned: List<String>.from(
        (map['cleanersAssigned'] as List<dynamic>? ?? []).map((e) => '$e'),
      ),
      addons: (map['addons'] as List<dynamic>? ?? [])
          .map((addon) => BookingAddon.fromMap(addon as Map<String, dynamic>))
          .toList(),
      payment: map['payment'] != null
          ? BookingPayment.fromMap(map['payment'] as Map<String, dynamic>)
          : null,
      user: map['userId'] != null
          ? (map['userId'] is Map<String, dynamic>
                ? BookingUser.fromMap(map['userId'] as Map<String, dynamic>)
                : null)
          : null,
      package: map['package'] != null
          ? BookingPackage.fromMap(map['package'] as Map<String, dynamic>)
          : null,
      vehicleId: map['vehicleId']?.toString(),
      buildingId: map['buildingId'] is String
          ? map['buildingId'] as String
          : map['buildingId'] is Map<String, dynamic>
          ? (map['buildingId'] as Map<String, dynamic>)['_id']?.toString()
          : null,
      buildingInfo: map['buildingId'] is Map<String, dynamic>
          ? BuildingInfo.fromMap(map['buildingId'] as Map<String, dynamic>)
          : null,
      totalPrice: map['totalPrice'] is num
          ? (map['totalPrice'] as num).toDouble()
          : double.tryParse(map['totalPrice']?.toString() ?? ''),
      startDate: _parseDate(map['startDate']),
      endDate: _parseDate(map['endDate']),
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    try {
      return DateTime.parse(value.toString()).toLocal();
    } catch (e) {
      if (kDebugMode) {
        print('CleanerBooking date parse error: $e');
      }
      return null;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'bookingId': bookingId,
      'status': status,
      'bookingType': bookingType,
      'cleanersAssigned': cleanersAssigned,
      'addons': addons.map((addon) => addon.toMap()).toList(),
      'payment': payment?.toMap(),
      'userId': user?.toMap(),
      'package': package?.toMap(),
      'vehicleId': vehicleId,
      'buildingId': buildingInfo?.toMap() ?? buildingId,
      'totalPrice': totalPrice,
      'startDate': startDate?.toUtc().toIso8601String(),
      'endDate': endDate?.toUtc().toIso8601String(),
      'createdAt': createdAt?.toUtc().toIso8601String(),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
    };
  }

  bool get isCompleted => status.toUpperCase() == 'COMPLETED';

  bool isScheduledFor(DateTime date) {
    if (startDate == null) return false;
    final localDate = startDate!.toLocal();
    return localDate.year == date.year &&
        localDate.month == date.month &&
        localDate.day == date.day;
  }
}

class BookingPayment {
  BookingPayment({required this.method, required this.status});

  final String method;
  final String status;

  factory BookingPayment.fromMap(Map<String, dynamic> map) {
    return BookingPayment(
      method: map['method']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'method': method, 'status': status};
  }
}

class BookingUser {
  BookingUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.apartmentNumber,
    this.image,
    this.buildingId,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String? apartmentNumber;
  final String? image;
  final String? buildingId;

  factory BookingUser.fromMap(Map<String, dynamic> map) {
    return BookingUser(
      id: map['_id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      apartmentNumber: map['apartmentNumber']?.toString(),
      image: map['image']?.toString(),
      buildingId: map['buildingId']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'apartmentNumber': apartmentNumber,
      'image': image,
      'buildingId': buildingId,
    };
  }
}

class BookingPackage {
  BookingPackage({
    required this.packageId,
    required this.totalSessions,
    required this.sessions,
    required this.price,
  });

  final PackageInfo? packageId;
  final int totalSessions;
  final List<PackageSession> sessions;
  final double? price;

  factory BookingPackage.fromMap(Map<String, dynamic> map) {
    return BookingPackage(
      packageId: map['packageId'] != null
          ? PackageInfo.fromMap(map['packageId'] as Map<String, dynamic>)
          : null,
      totalSessions: map['totalSessions'] is num
          ? (map['totalSessions'] as num).toInt()
          : int.tryParse(map['totalSessions']?.toString() ?? '') ?? 0,
      sessions: (map['sessions'] as List<dynamic>? ?? [])
          .map(
            (session) =>
                PackageSession.fromMap(session as Map<String, dynamic>),
          )
          .toList(),
      price: map['price'] is num
          ? (map['price'] as num).toDouble()
          : double.tryParse(map['price']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'packageId': packageId?.toMap(),
      'totalSessions': totalSessions,
      'sessions': sessions.map((session) => session.toMap()).toList(),
      'price': price,
    };
  }
}

class PackageInfo {
  PackageInfo({
    required this.id,
    required this.name,
    required this.frequency,
    required this.description,
    this.isAddOn = false,
  });

  final String id;
  final String name;
  final String frequency;
  final String description;
  final bool isAddOn;

  factory PackageInfo.fromMap(Map<String, dynamic> map) {
    return PackageInfo(
      id: map['_id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      frequency: map['frequency']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      isAddOn: map['isAddOn'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'frequency': frequency,
      'description': description,
      'isAddOn': isAddOn,
    };
  }
}

class PackageSession {
  PackageSession({
    required this.id,
    required this.isCompleted,
    this.date,
    this.completedBy,
    this.images = const [],
  });

  final String id;
  final bool isCompleted;
  final DateTime? date;
  final String? completedBy;
  final List<String> images;

  factory PackageSession.fromMap(Map<String, dynamic> map) {
    // Handle completedBy as either string or array
    String? completedByStr;
    if (map['completedBy'] != null) {
      if (map['completedBy'] is List) {
        final list = map['completedBy'] as List;
        completedByStr = list.isNotEmpty ? list.first.toString() : null;
      } else {
        completedByStr = map['completedBy']?.toString();
      }
    }

    return PackageSession(
      id: map['_id']?.toString() ?? '',
      isCompleted: map['isCompleted'] == true,
      date: CleanerBooking._parseDate(map['date']),
      completedBy: completedByStr,
      images: List<String>.from(
        (map['images'] as List<dynamic>? ?? []).map((e) => '$e'),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'isCompleted': isCompleted,
      'date': date?.toUtc().toIso8601String(),
      'completedBy': completedBy,
      'images': images,
    };
  }
}

class BookingAddon {
  BookingAddon({
    required this.addonId,
    required this.totalSessions,
    required this.sessions,
    this.price,
    this.dates = const [],
  });

  final String addonId;
  final int totalSessions;
  final List<AddonSession> sessions;
  final double? price;
  final List<DateTime> dates;

  factory BookingAddon.fromMap(Map<String, dynamic> map) {
    return BookingAddon(
      addonId: map['addonId']?.toString() ?? '',
      totalSessions: map['totalSessions'] is num
          ? (map['totalSessions'] as num).toInt()
          : int.tryParse(map['totalSessions']?.toString() ?? '') ?? 0,
      sessions: (map['sessions'] as List<dynamic>? ?? [])
          .map(
            (session) => AddonSession.fromMap(session as Map<String, dynamic>),
          )
          .toList(),
      price: map['price'] is num
          ? (map['price'] as num).toDouble()
          : double.tryParse(map['price']?.toString() ?? ''),
      dates: (map['dates'] as List<dynamic>? ?? [])
          .map((date) => CleanerBooking._parseDate(date))
          .whereType<DateTime>()
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'addonId': addonId,
      'totalSessions': totalSessions,
      'sessions': sessions.map((session) => session.toMap()).toList(),
      'price': price,
      'dates': dates.map((date) => date.toUtc().toIso8601String()).toList(),
    };
  }
}

class AddonSession {
  AddonSession({
    required this.id,
    required this.isCompleted,
    this.date,
    this.completedBy,
    this.images = const [],
  });

  final String id;
  final bool isCompleted;
  final DateTime? date;
  final String? completedBy;
  final List<String> images;

  factory AddonSession.fromMap(Map<String, dynamic> map) {
    return AddonSession(
      id: map['_id']?.toString() ?? '',
      isCompleted: map['isCompleted'] == true,
      date: CleanerBooking._parseDate(map['date']),
      completedBy: map['completedBy']?.toString(),
      images: List<String>.from(
        (map['images'] as List<dynamic>? ?? []).map((e) => '$e'),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'isCompleted': isCompleted,
      'date': date?.toUtc().toIso8601String(),
      'completedBy': completedBy,
      'images': images,
    };
  }
}

class BuildingInfo {
  BuildingInfo({required this.id, required this.name});

  final String id;
  final String name;

  factory BuildingInfo.fromMap(Map<String, dynamic> map) {
    return BuildingInfo(
      id: map['_id']?.toString() ?? '',
      name: map['buildingName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'_id': id, 'buildingName': name};
  }
}

class BookingPagination {
  BookingPagination({
    required this.page,
    required this.limit,
    required this.total,
  });

  final int page;
  final int limit;
  final int total;

  factory BookingPagination.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return BookingPagination(page: 1, limit: 10, total: 0);
    }
    return BookingPagination(
      page: map['page'] is num
          ? (map['page'] as num).toInt()
          : int.tryParse(map['page']?.toString() ?? '') ?? 1,
      limit: map['limit'] is num
          ? (map['limit'] as num).toInt()
          : int.tryParse(map['limit']?.toString() ?? '') ?? 10,
      total: map['total'] is num
          ? (map['total'] as num).toInt()
          : int.tryParse(map['total']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'page': page, 'limit': limit, 'total': total};
  }
}
