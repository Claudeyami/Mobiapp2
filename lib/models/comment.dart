class Comment {
  final int id;
  final String content;
  final String user;

  Comment({
    required this.id,
    required this.content,
    required this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    int? parsedId;
    final idValue = json['id'] ?? json['CommentID'] ?? json['commentId'] ?? json['comment_id'];
    if (idValue != null) {
      if (idValue is int) {
        parsedId = idValue;
      } else if (idValue is String) {
        parsedId = int.tryParse(idValue);
      } else if (idValue is double) {
        parsedId = idValue.toInt();
      }
    }
    
    if (parsedId == null) {
      throw FormatException('Comment id is required but was null or invalid. Available keys: ${json.keys.join(", ")}');
    }

    final content = json['content'] ?? json['Content'] ?? '';
    final user = json['user'] ?? 
                 json['userName'] ?? 
                 json['username'] ?? 
                 json['User'] ??
                 json['UserName'] ??
                 'Ẩn danh';

    return Comment(
      id: parsedId,
      content: content,
      user: user,
    );
  }
}
