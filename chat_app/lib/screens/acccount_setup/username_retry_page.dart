import 'dart:async';
import 'package:chat_app/main.dart';
import 'package:chat_app/screens/acccount_setup/setup_account_page.dart';
import 'package:chat_app/screens/auth_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../api/api_functions.dart';

class UsernameRetryPage extends StatefulWidget {
  const UsernameRetryPage({super.key});

  @override
  State<UsernameRetryPage> createState() => _UsernameRetryPageState();
}

class _UsernameRetryPageState extends State<UsernameRetryPage> {
  final TextEditingController usernameController = TextEditingController();

  bool isLoading = false;
  bool? isUsernameAvailable;
  String? usernameCheckError;
  bool isCheckingUsername = false;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    usernameController.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    usernameController.removeListener(_onUsernameChanged);
    usernameController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  bool _isValidUsername(String username) {
    final regex = RegExp(r'^[a-zA-Z0-9_]{3,16}$');
    return regex.hasMatch(username);
  }

  void _onUsernameChanged() {
    final username = usernameController.text.trim();
    if (username.isEmpty) {
      setState(() {
        isUsernameAvailable = null;
        usernameCheckError = null;
      });
      return;
    }
    _debounce?.cancel();

    if (!_isValidUsername(username)) {
      setState(() {
        isCheckingUsername = false;
        usernameCheckError = "Username must be 3-16 chars, letters/numbers/_ only";
        isUsernameAvailable = null;
      });
      return;
    }

    setState(() {
      isCheckingUsername = true;
      isUsernameAvailable = null;
      usernameCheckError = null;
    });

    _debounce = Timer(const Duration(seconds: 1), () async {
      try {
        final available = await checkUsername(username);
        if (mounted) {
          setState(() {
            isCheckingUsername = false;
            isUsernameAvailable = available;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            isCheckingUsername = false;
            usernameCheckError = 'Network error';
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header
              Text(
                "Choose a username",
                style: textTheme.headlineMedium,
              ),
              const SizedBox(height: 40),

              // Username field with status icon
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  _buildTextField(usernameController, "Username", Icons.person),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildUsernameStatus(),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Error text
              if (usernameCheckError != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    usernameCheckError!,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 13,
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (isUsernameAvailable == false ||
                              usernameCheckError != null ||
                              usernameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Invalid username'),
                                backgroundColor: theme.colorScheme.error,
                              ),
                            );
                            return;
                          }

                          setState(() => isLoading = true);

                          final currentUser = FirebaseAuth.instance.currentUser;

                          if(currentUser == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('User not authenticated'),
                                backgroundColor: theme.colorScheme.error,
                              ),
                            );
                            setState(() => isLoading = false);
                            navigatorKey.currentState?.pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const AuthPage(),
                              ),
                            );
                            return;
                          }

                          final token = await currentUser.getIdToken();

                          if (token == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Failed to retrieve authentication token'),
                                backgroundColor: theme.colorScheme.error,
                              ),
                            );
                            setState(() => isLoading = false);
                            navigatorKey.currentState?.pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const AuthPage(),
                              ),
                            );
                            return;
                          }

                          final result = await updateUsername(
                            username: usernameController.text.trim(),
                            token: token,
                          );

                          if (!mounted) return;

                          if(result['status'] == UpdateUsernameResponseType.usernameUpdatedSuccessfully) {
                            navigatorKey.currentState?.pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const SetupAccountPage(),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result['message']),
                                backgroundColor: theme.colorScheme.error,
                              ),
                            );
                          }
                          setState(() => isLoading = false);
                        },
                  child: isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : const Text("Continue"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameStatus() {
    if (usernameController.text.isEmpty) return const SizedBox();
    if (isCheckingUsername) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (isUsernameAvailable == true) {
      return const Icon(Icons.check_circle, color: Colors.green, size: 20);
    }
    if (isUsernameAvailable == false) {
      return Icon(Icons.cancel, color: Theme.of(context).colorScheme.error, size: 20);
    }
    return const SizedBox();
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }
}