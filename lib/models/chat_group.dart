class ChatGroup {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final int memberCount;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  ChatGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    this.memberCount = 0,
    this.lastMessage,
    this.lastMessageTime,
  });

  factory ChatGroup.fromJson(Map<String, dynamic> json) {
    return ChatGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      memberCount: json['member_count'] as int? ?? 0,
      lastMessage: json['last_message'] as String?,
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'member_count': memberCount,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime?.toIso8601String(),
    };
  }
}