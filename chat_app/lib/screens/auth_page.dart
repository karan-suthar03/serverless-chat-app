import 'dart:convert';

import 'package:chat_app/main.dart';
import 'package:chat_app/screens/acccount_setup/setup_account_page.dart';
import 'package:chat_app/screens/acccount_setup/username_retry_page.dart';
import 'package:chat_app/screens/main/main_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_functions.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  bool isLogin = true;
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
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void toggleMode() {
    setState(() {
      isLogin = !isLogin;
      isUsernameAvailable = null;
      usernameCheckError = null;
      usernameController.clear();
    });
  }

  /// Validate username format
  bool _isValidUsername(String username) {
    final regex = RegExp(r'^[a-zA-Z0-9_]{3,16}$'); // 3-16 chars, letters/numbers/_
    return regex.hasMatch(username);
  }

  /// Debounced username checking
  void _onUsernameChanged() {
    if (isLogin) return;

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
        usernameCheckError =
            "Username must be 3-16 chars, letters/numbers/_ only";
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
        setState(() {
          isCheckingUsername = false;
          isUsernameAvailable = available;
        });
      } catch (e) {
        setState(() {
          isCheckingUsername = false;
          usernameCheckError = 'Network error';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header
              Text(
                isLogin ? "Login" : "Sign Up",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),

              Column(
                children: [
                  // Username field (signup only)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: isLogin
                        ? const SizedBox.shrink()
                        : Column(
                            children: [
                              Stack(
                                alignment: Alignment.centerRight,
                                children: [
                                  _buildTextField(
                                    usernameController,
                                    "Username",
                                    Icons.person,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: _buildUsernameStatus(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (usernameCheckError != null)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    usernameCheckError!,
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 13),
                                  ),
                                ),
                              const SizedBox(height: 16),
                            ],
                          ),
                  ),

                  _buildTextField(emailController, "Email", Icons.mail_outline),
                  const SizedBox(height: 16),
                  _buildTextField(passwordController, "Password", Icons.lock,
                      obscure: true),
                ],
              ),

              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() => isLoading = true);

                          try {
                            if (isLogin) {
                              await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                              );
                              final currentUser = FirebaseAuth.instance.currentUser;
                              if (currentUser != null) {
                                final token = await currentUser.getIdToken(true);
                                if (token == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to retrieve token'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  setState(() => isLoading = false);
                                  return;
                                }
                                final result = await getUserData(token: token);
                                if (result['status'] == GenericResponseType.success) {
                                  final user = result['user'];
                                  if (user != null) {
                                    if(user['is_profile_complete']==true) {
                                      final pref = await SharedPreferences.getInstance();
                                      final data = {
                                        'isSetUp': true
                                      };
                                      await pref.setString('user', jsonEncode(data));
                                      navigatorKey.currentState?.pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) => const MainPage(),
                                        ),
                                      );
                                    } else {
                                      if(user['username'] != null) {
                                        navigatorKey.currentState?.pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) => const SetupAccountPage(),
                                          ),
                                        );
                                      }else{
                                        navigatorKey.currentState?.pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) => const UsernameRetryPage(),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                  return;
                                }
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Something went wrong.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else {
                              if (isUsernameAvailable == false ||
                                  usernameCheckError != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Invalid username'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                              ).then((userCredential) async {
                                final token = await userCredential.user?.getIdToken();
                                // Call backend createUser API
                                final result = await createUser(
                                  username: usernameController.text.trim(),
                                  token: token,
                                );
                                switch (result['status']) {
                                  case CreateUserResponseType.createdSuccessfully:
                                    navigatorKey.currentState?.pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => const SetupAccountPage(),
                                      ),
                                    );
                                    break;
                                  case CreateUserResponseType.usernameFailed:
                                    navigatorKey.currentState?.pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => const UsernameRetryPage(),
                                      ),
                                    );
                                  case CreateUserResponseType.userAlreadyExists:
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(result['message'] ?? 'User already exists'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    break;
                                  case CreateUserResponseType.unknownError:
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(result['message'] ?? 'unknownError'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    break;
                                  default:
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(result['message'] ?? 'Error occurred'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                }
                              });
                            }
                          } finally {
                            if (mounted) {
                              setState(() => isLoading = false);
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(isLogin ? "Login" : "Create Account"),
                ),
              ),
              const SizedBox(height: 20),

              // Toggle
              TextButton(
                onPressed: toggleMode,
                child: Text(
                  isLogin
                      ? "Don't have an account? Sign Up"
                      : "Already have an account? Login",
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Username check icon widget
  Widget _buildUsernameStatus() {
    if (isLogin || usernameController.text.isEmpty) return const SizedBox();
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
      return const Icon(Icons.cancel, color: Colors.red, size: 20);
    }
    return const SizedBox();
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      IconData icon, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
