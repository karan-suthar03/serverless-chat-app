import 'package:flutter/material.dart';


typedef SplashFinishedCallback = void Function(BuildContext context);

class SplashScreen extends StatefulWidget {
  final SplashFinishedCallback? onFinished;
  const SplashScreen({super.key, this.onFinished});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    _fadeController.forward();
    _slideController.forward();
    Future.delayed(const Duration(seconds: 1), () {
      if (widget.onFinished != null) {
        widget.onFinished!(context);
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF232526), Color(0xFF414345)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: const Icon(
                    Icons.flash_on_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Chat App',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF00C6FF),
                    letterSpacing: 1.5,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SlideTransition(
                position: _slideAnimation,
                child: Text(
                  'Connect and chat instantly.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeTransition(
                opacity: _fadeAnimation,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C6FF)),
                  backgroundColor: Colors.white24,
                  strokeWidth: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
