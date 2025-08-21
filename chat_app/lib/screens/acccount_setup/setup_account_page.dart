import 'dart:convert';

import 'package:chat_app/api/api_functions.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/screens/auth_page.dart';
import 'package:chat_app/screens/main/main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupAccountPage extends StatefulWidget {
  const SetupAccountPage({super.key});

  @override
  State<SetupAccountPage> createState() => _SetupAccountPageState();
}

class _SetupAccountPageState extends State<SetupAccountPage> {
  final TextEditingController displayNameController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initializeSharePreferenceUserData(false);
  }

  @override
  void dispose() {
    displayNameController.dispose();
    super.dispose();
  }
  Future<void> initializeSharePreferenceUserData(bool isSetUp) async {
    final user = {
      'isSetUp': isSetUp
    };
    final pref = await SharedPreferences.getInstance();
    await pref.setString('user', jsonEncode(user));
    return;
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
                "Set up your account",
                style: textTheme.headlineMedium,
              ),
              const SizedBox(height: 40),

              // Profile image placeholder
              GestureDetector(
                onTap: () {
                  // TODO: open image picker
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.surface,
                  child: Icon(
                    Icons.camera_alt,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Display name field
              TextField(
                controller: displayNameController,
                decoration: const InputDecoration(
                  hintText: "Display Name",
                  prefixIcon: Icon(Icons.badge, size: 20),
                ),
              ),

              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() => isLoading = true);

                          final displayName = displayNameController.text.trim();
                          final currentUser = FirebaseAuth.instance.currentUser;
                          if (currentUser == null) {
                            navigatorKey.currentState?.pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const AuthPage(),
                              ),
                            );
                            return;
                          }

                          final token = await currentUser.getIdToken();

                          if (token == null) {
                             if (!mounted) return;
                            setState(() => isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to get authentication token. Please try again.')),
                            );
                            return;
                          }

                          final result = await finalizeAccountSetup(
                            token: token, 
                            type: FinalizeAccountSetupRequestType.displayName,
                            displayName: displayName,
                            );
                          
                          if (!mounted) return;
                          setState(() => isLoading = false);

                          switch (result['status']) {
                            case GenericResponseType.success:
                              initializeSharePreferenceUserData(true);
                              navigatorKey.currentState?.pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const MainPage(),
                                ),
                              );
                              break;
                            case GenericResponseType.failure:
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(result['message'])),
                              );
                              break;
                            default:
                          }
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
                      : const Text("Save"),
                ),
              ),
              const SizedBox(height: 16),

              // Skip button
              TextButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() => isLoading = true);
                        final currentUser = FirebaseAuth.instance.currentUser;
                        if (currentUser == null) {
                          navigatorKey.currentState?.pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const AuthPage(),
                            ),
                          );
                          return;
                        }
                        final token = await currentUser.getIdToken();
                        if (token == null) {
                          if (!mounted) return;
                          setState(() => isLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to get authentication token. Please try again.')),
                          );
                          return;
                        }
                        final result = await finalizeAccountSetup(
                          token: token,
                          type: FinalizeAccountSetupRequestType.skip,
                        );
                        
                        if (!mounted) return;
                        setState(() => isLoading = false);

                        switch (result['status']) {
                          case GenericResponseType.success:
                            initializeSharePreferenceUserData(true);
                            navigatorKey.currentState?.pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const MainPage(),
                              ),
                            );
                            break;
                          case GenericResponseType.failure:
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result['message'])),
                            );
                            break;
                          default:
                        }
                      },
                child: const Text("Skip for now"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}