import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login_screen.dart';
import '../domain/auth_provider.dart';
import '../../relationship/domain/relationship_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    // Small delay for branding/smoothness
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    final token = ref.read(authProvider).token;
    
    if (token != null) {
      // User is logged in, check relationships
      try {
        await ref.read(relationshipProvider.notifier).fetchRelationships();
        if (!mounted) return;
        
        final relState = ref.read(relationshipProvider);
        if (relState.relationships.isNotEmpty) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/relationship-setup');
        }
      } catch (e) {
        // If fetch fails (e.g. invalid token), go to login
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      // Not logged in
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite, color: Colors.white, size: 80),
            const SizedBox(height: 24),
            const Text(
              'BONDLY',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
