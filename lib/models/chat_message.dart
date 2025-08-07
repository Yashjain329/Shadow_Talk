import 'package:shadow_talk_flutter/config/supabase_config.dart';

class ChatMessage {
  final String id;
  final String groupId;
  final String userId;
  final String message;
  final DateTime timestamp;
  final String? userDisplayName;

  ChatMessage({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.message,
    required this.timestamp,
    this.userDisplayName,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      userId: json['user_id'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userDisplayName: json['user_display_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'user_id': userId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'user_display_name': userDisplayName,
    };
  }

  bool get isFromCurrentUser => userId == SupabaseConfig.currentUserId;
}