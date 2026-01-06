class LoginResponse {
  final bool ok;
  final int? userId;

  LoginResponse({
    required this.ok,
    this.userId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    int? parsedUserId;
    
    final userIdValue = json['userId'] ?? json['user_id'] ?? json['id'] ?? json['user'];
    if (userIdValue != null) {
      if (userIdValue is int) {
        parsedUserId = userIdValue;
      } else if (userIdValue is String) {
        parsedUserId = int.tryParse(userIdValue);
      } else if (userIdValue is double) {
        parsedUserId = userIdValue.toInt();
      }
    }

    return LoginResponse(
      ok: json['ok'] ?? false,
      userId: parsedUserId,
    );
  }
}
