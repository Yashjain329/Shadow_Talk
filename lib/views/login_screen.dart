import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../widgets/loading_widget.dart';
import 'group_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF121212), Color(0xFF1E1E1E)],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Title
                const Icon(
                  Icons.electric_bolt_outlined,
                  size: 80,
                  color: Color(0xFFE6DF0A),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Shadow Talk',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00FFD1),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Chat App',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFB0B0B0),
                  ),
                ),
                const SizedBox(height: 48),

                Consumer<ChatViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.isLoading) {
                      return const LoadingWidget();
                    }

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _handleLogin(context, viewModel),
                        child: const Text(
                          'Enter Anonymously',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),
                Consumer<ChatViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.error != null) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Text(
                          viewModel.error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin(BuildContext context, ChatViewModel viewModel) async {
    final success = await viewModel.signInAnonymously();
    if (success && context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const GroupScreen()),
      );
    }
  }
}