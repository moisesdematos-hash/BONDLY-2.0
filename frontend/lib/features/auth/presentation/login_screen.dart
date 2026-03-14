import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Premium dark blue/black
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Image.asset(
                  'assets/images/welcome_couples.png',
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                'Bondly',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40, 
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Nutrindo conexões reais com IA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: authState.isLoading
                  ? null
                  : () {
                      ref.read(authProvider.notifier).login(
                            _emailController.text,
                            _passwordController.text,
                          ).then((_) async {
                            if (mounted && ref.read(authProvider).token != null) {
                              // After login, fetch relationships to decide where to go
                              await ref.read(relationshipProvider.notifier).fetchRelationships();
                              if (mounted) {
                                final relState = ref.read(relationshipProvider);
                                if (relState.relationships.isNotEmpty) {
                                  Navigator.pushReplacementNamed(context, '/dashboard');
                                } else {
                                  Navigator.pushReplacementNamed(context, '/relationship-setup');
                                }
                              }
                            }
                          });
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
              ),
              child: authState.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Entrar'),
            ),
            if (authState.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  authState.error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text('Não tem uma conta? Cadastre-se'),
            ),

          ],
        ),
      ),
    );
  }
}
