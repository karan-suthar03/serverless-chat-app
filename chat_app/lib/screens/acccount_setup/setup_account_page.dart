import 'package:flutter/material.dart';

class SetupAccountPage extends StatefulWidget {
  const SetupAccountPage({super.key});

  @override
  State<SetupAccountPage> createState() => _SetupAccountPageState();
}

class _SetupAccountPageState extends State<SetupAccountPage> {
  final TextEditingController displayNameController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    displayNameController.dispose();
    super.dispose();
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
              const Text(
                "Set up your account",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),

              // Profile image placeholder
              GestureDetector(
                onTap: () {
                  // TODO: open image picker
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.camera_alt, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 24),

              // Display name field
              TextField(
                controller: displayNameController,
                decoration: InputDecoration(
                  hintText: "Display Name",
                  prefixIcon: const Icon(Icons.badge, size: 20),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Save button
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

                          // TODO: save display name & photo to Firebase / backend
                          await Future.delayed(const Duration(seconds: 1));

                          if (mounted) {
                            setState(() => isLoading = false);
                            Navigator.pushReplacementNamed(context, "/home");
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
                      : const Text("Save"),
                ),
              ),
              const SizedBox(height: 16),

              // Skip button
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, "/home");
                },
                child: const Text(
                  "Skip for now",
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
