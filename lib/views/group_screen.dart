import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../widgets/group_card.dart';
import '../widgets/loading_widget.dart';
import 'chat_screen.dart';
import 'login_screen.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatViewModel>().loadGroups();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚡ Shadow Talk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: Consumer<ChatViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.groups.isEmpty) {
            return const LoadingWidget();
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.loadGroups(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.groups.length,
              itemBuilder: (context, index) {
                final group = viewModel.groups[index];
                return GroupCard(
                  group: group,
                  onTap: () => _joinGroup(context, group.id, group.name),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateGroupDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _joinGroup(BuildContext context, String groupId, String groupName) async {
    final viewModel = context.read<ChatViewModel>();
    await viewModel.joinGroup(groupId);

    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(groupId: groupId, groupName: groupName),
        ),
      );
    }
  }

  void _showCreateGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                hintText: 'Enter group name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter group description',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _nameController.clear();
              _descriptionController.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _createGroup(context),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _createGroup(BuildContext context) async {
    if (_nameController.text.trim().isEmpty) return;

    final viewModel = context.read<ChatViewModel>();
    final success = await viewModel.createGroup(
      _nameController.text.trim(),
      _descriptionController.text.trim(),
    );

    if (success && context.mounted) {
      _nameController.clear();
      _descriptionController.clear();
      Navigator.of(context).pop();
    }
  }

  void _handleLogout(BuildContext context) async {
    await context.read<ChatViewModel>().signOut();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }
}