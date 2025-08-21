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
  bool _isFormValid = false;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    usernameController.addListener(_onUsernameChanged);
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    usernameController.removeListener(_onUsernameChanged);
    emailController.removeListener(_validateForm);
    passwordController.removeListener(_validateForm);
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
      emailController.clear();
      passwordController.clear();
      _validateForm();
    });
  }

  bool _isValidUsername(String username) {
    final regex = RegExp(r'^[a-zA-Z0-9_]{3,16}$');
    return regex.hasMatch(username);
  }

  void _validateForm() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final username = usernameController.text.trim();

    final isEmailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
    final isPasswordValid = password.length >= 6;

    if (isLogin) {
      setState(() {
        _isFormValid = isEmailValid && isPasswordValid;
      });
    } else {
      final isUsernameFieldValid =
          _isValidUsername(username) && isUsernameAvailable == true;
      setState(() {
        _isFormValid = isEmailValid && isPasswordValid && isUsernameFieldValid;
      });
    }
  }

  void _onUsernameChanged() {
    if (isLogin) return;

    final username = usernameController.text.trim();
    if (username.isEmpty) {
      setState(() {
        isUsernameAvailable = null;
        usernameCheckError = null;
        isCheckingUsername = false;
        _debounce?.cancel();
      });
      _validateForm();
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
      _validateForm();
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
            if (available == false) {
              usernameCheckError = "Username is already taken";
            }
          });
          _validateForm();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            isCheckingUsername = false;
            usernameCheckError = 'Network error checking username';
          });
          _validateForm();
        }
      }
    });
  }

  Future<void> _submitForm() async {
    setState(() => isLoading = true);

    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          final token = await currentUser.getIdToken(true);
          if (token == null) {
            _showErrorSnackBar('Failed to retrieve authentication token.');
            return;
          }
          final result = await getUserData(token: token);
          if (result['status'] == GenericResponseType.success && mounted) {
            final user = result['user'];
            if (user != null) {
              if (user['is_profile_complete'] == true) {
                final pref = await SharedPreferences.getInstance();
                await pref.setString('user', jsonEncode({'isSetUp': true}));
                navigatorKey.currentState?.pushReplacement(
                  MaterialPageRoute(builder: (context) => const MainPage()),
                );
              } else {
                if (user['username'] != null) {
                  navigatorKey.currentState?.pushReplacement(
                    MaterialPageRoute(builder: (context) => const SetupAccountPage()),
                  );
                } else {
                  navigatorKey.currentState?.pushReplacement(
                    MaterialPageRoute(builder: (context) => const UsernameRetryPage()),
                  );
                }
              }
            } else {
              _showErrorSnackBar('Could not retrieve user data.');
            }
          } else {
            _showErrorSnackBar(result['message'] ?? 'An unknown error occurred.');
          }
        }
      } else {
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        final token = await userCredential.user?.getIdToken();
        if (token == null) {
          _showErrorSnackBar('Could not create user. Please try again.');
          return;
        }

        final result = await createUser(
          username: usernameController.text.trim(),
          token: token,
        );

        if (!mounted) return;

        switch (result['status']) {
          case CreateUserResponseType.createdSuccessfully:
            navigatorKey.currentState?.pushReplacement(
              MaterialPageRoute(builder: (context) => const SetupAccountPage()),
            );
            break;
          case CreateUserResponseType.usernameFailed:
            navigatorKey.currentState?.pushReplacement(
              MaterialPageRoute(builder: (context) => const UsernameRetryPage()),
            );
            break;
          default:
            _showErrorSnackBar(result['message'] ?? 'An unknown error occurred.');
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred. Please check your credentials.';
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        message = 'Invalid email or password.';
      } else if (e.code == 'email-already-in-use') {
        message = 'This email is already registered. Please log in.';
      } else if (e.code == 'weak-password') {
        message = 'The password is too weak.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      }
      _showErrorSnackBar(message);
    } catch (e) {
      _showErrorSnackBar('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
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
                isLogin ? "Login" : "Sign Up",
                style: textTheme.headlineMedium,
              ),
              const SizedBox(height: 40),

              Column(
                children: [
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: isLogin
                        ? const SizedBox.shrink()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                              if (usernameCheckError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                                  child: Text(
                                    usernameCheckError!,
                                    style: TextStyle(
                                        color: theme.colorScheme.error,
                                        fontSize: 13),
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
                  onPressed: isLoading || !_isFormValid ? null : _submitForm,
                  child: isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : Text(isLogin ? "Login" : "Create Account"),
                ),
              ),
              const SizedBox(height: 20),

              // Toggle
              TextButton(
                onPressed: isLoading ? null : toggleMode,
                child: Text(
                  isLogin
                      ? "Don't have an account? Sign Up"
                      : "Already have an account? Login",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildUsernameStatus() {
    if (isLogin || usernameController.text.isEmpty || !_isValidUsername(usernameController.text.trim())) return const SizedBox();
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
      ),
    );
  }
}