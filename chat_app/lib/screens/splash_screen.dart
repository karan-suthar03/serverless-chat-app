import 'dart:async';
import 'dart:convert';
import 'package:chat_app/api/api_functions.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/screens/acccount_setup/setup_account_page.dart';
import 'package:chat_app/screens/acccount_setup/username_retry_page.dart';
import 'package:chat_app/screens/auth_page.dart';
import 'package:chat_app/screens/main/main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble,
              size: 80,
              color: Colors.black,
            ),
            SizedBox(height: 24),
            Text(
              "Chat App",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkAuthStatus() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final currentUser = FirebaseAuth.instance.currentUser;
    final pref = await SharedPreferences.getInstance();

    if (currentUser == null) {
      _navigateTo(const AuthPage());
      return;
    }

    final userData = pref.getString('user');

    if (userData != null) {
      final userMap = jsonDecode(userData);
      if (userMap['isSetUp'] == true) {
        _navigateTo(const MainPage());
        return;
      }
    }

    try {
      final token = await currentUser.getIdToken(true);
      final result = await getUserData(token: token ?? '');

      if (result['status'] == GenericResponseType.success) {
        final user = result['user'];
        if (user != null) {
          await _handleUser(user);
        } else {
          _showOfflineFallback();
        }
      } else {
        _showOfflineFallback();
      }
    } catch (e) {
      _showOfflineFallback();
    }
  }

  void _showOfflineFallback() {
    scaffoldMessengerKey.currentState?.showSnackBar(
      const SnackBar(
        content: Text(
          'No internet connection. Please try again later.',
        ),
      ),
    );
    _navigateTo(const AuthPage());
  }


  Future<void> _handleUser(Map<String, dynamic> user) async {
    final pref = await SharedPreferences.getInstance();

    if (user['is_profile_complete'] == true) {
      await pref.setString('user', jsonEncode({'isSetUp': true}));
      _navigateTo(const MainPage());
    } else if (user['username'] != null) {
      _navigateTo(const SetupAccountPage());
    } else {
      _navigateTo(const UsernameRetryPage());
    }
  }

  void _navigateTo(Widget page) {
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }
}
