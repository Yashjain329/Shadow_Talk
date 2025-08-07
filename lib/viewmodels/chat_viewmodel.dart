import 'package:flutter/material.dart';
import 'package:shadow_talk_flutter/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_group.dart';
import '../models/chat_message.dart';
import '../repositories/chat_repository.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _repository = ChatRepository();

  bool _isLoading = false;
  String? _error;
  List<ChatGroup> _groups = [];
  List<ChatMessage> _messages = [];
  RealtimeChannel? _messageSubscription;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ChatGroup> get groups => _groups;
  List<ChatMessage> get messages => _messages;
  bool get isAuthenticated => SupabaseConfig.isAuthenticated;

  Future<bool> signInAnonymously() async {
    _setLoading(true);
    try {
      await _repository.signInAnonymously();
      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _groups.clear();
    _messages.clear();
    _messageSubscription?.unsubscribe();
    notifyListeners();
  }

  Future<void> loadGroups() async {
    _setLoading(true);
    try {
      _groups = await _repository.getGroups();
      _clearError();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createGroup(String name, String description) async {
    _setLoading(true);
    try {
      final group = await _repository.createGroup(name, description);
      _groups.insert(0, group);
      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> joinGroup(String groupId) async {
    try {
      await _repository.joinGroup(groupId);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadMessages(String groupId) async {
    _setLoading(true);
    try {
      _messages = await _repository.getMessages(groupId);
      _clearError();
      _messageSubscription?.unsubscribe();
      _messageSubscription = _repository.subscribeToMessages(
        groupId,
            (message) {
          if (!_messages.any((m) => m.id == message.id)) {
            _messages.add(message);
            notifyListeners();
          }
        },
      );
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendMessage(String groupId, String message) async {
    try {
      await _repository.sendMessage(groupId, message);
      _clearError();
    } catch (e) {
      _setError(e.toString());
    }
  }

  void clearMessages() {
    _messages.clear();
    _messageSubscription?.unsubscribe();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _messageSubscription?.unsubscribe();
    super.dispose();
  }
}