import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../config/supabase_config.dart';
import '../models/chat_group.dart';
import '../models/chat_message.dart';

class ChatRepository {
  final SupabaseClient _client = SupabaseConfig.client;
  final Uuid _uuid = const Uuid();
  Future<AuthResponse> signInAnonymously() async {
    return await _client.auth.signInAnonymously();
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<List<ChatGroup>> getGroups() async {
    final response = await _client
        .from('chat_groups')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ChatGroup.fromJson(json))
        .toList();
  }

  Future<ChatGroup> createGroup(String name, String description) async {
    final groupId = _uuid.v4();
    final now = DateTime.now();

    final groupData = {
      'id': groupId,
      'name': name,
      'description': description,
      'created_at': now.toIso8601String(),
      'member_count': 1,
    };

    await _client.from('chat_groups').insert(groupData);

    return ChatGroup.fromJson(groupData);
  }

  Future<void> joinGroup(String groupId) async {
    await _client.rpc('increment_member_count', params: {'group_id': groupId});
  }

  Future<List<ChatMessage>> getMessages(String groupId) async {
    final response = await _client
        .from('chat_messages')
        .select()
        .eq('group_id', groupId)
        .order('timestamp', ascending: true);

    return (response as List)
        .map((json) => ChatMessage.fromJson(json))
        .toList();
  }

  Future<ChatMessage> sendMessage(String groupId, String message) async {
    final messageId = _uuid.v4();
    final userId = SupabaseConfig.currentUserId!;
    final timestamp = DateTime.now();

    final messageData = {
      'id': messageId,
      'group_id': groupId,
      'user_id': userId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'user_display_name': 'Anonymous',
    };

    await _client.from('chat_messages').insert(messageData);
    await _client.from('chat_groups').update({
      'last_message': message,
      'last_message_time': timestamp.toIso8601String(),
    }).eq('id', groupId);

    return ChatMessage.fromJson(messageData);
  }

  RealtimeChannel subscribeToMessages(String groupId, Function(ChatMessage) onMessage) {
    return _client
        .channel('messages_$groupId')
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'chat_messages',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'group_id',
        value: groupId,
      ),
      callback: (payload) {
        final message = ChatMessage.fromJson(payload.newRecord);
        onMessage(message);
      },
    )
        .subscribe();
  }
}