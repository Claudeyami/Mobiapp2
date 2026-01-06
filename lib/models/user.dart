class User {
  final int id;
  final String email;
  final String name;
  final String? avatar;
  final String? phone;
  final DateTime? dateOfBirth;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    this.phone,
    this.dateOfBirth,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    int? parsedId;
    if (json['id'] != null) {
      if (json['id'] is int) {
        parsedId = json['id'] as int;
      } else if (json['id'] is String) {
        parsedId = int.tryParse(json['id'] as String);
      } else if (json['id'] is double) {
        parsedId = (json['id'] as double).toInt();
      }
    }

    DateTime? parsedDateOfBirth;
    if (json['dateOfBirth'] != null || json['date_of_birth'] != null) {
      final dateStr = json['dateOfBirth'] ?? json['date_of_birth'];
      if (dateStr is String) {
        parsedDateOfBirth = DateTime.tryParse(dateStr);
      }
    }

    return User(
      id: parsedId ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? json['username'] ?? '',
      avatar: json['avatar'],
      phone: json['phone'] ?? json['phoneNumber'],
      dateOfBirth: parsedDateOfBirth,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar': avatar,
      'phone': phone,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
    };
  }
}

