import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/bondly_theme.dart';

class BondlyLoadingWidget extends StatelessWidget {
  final String? message;
  const BondlyLoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: BondlyTheme.accent,
            strokeWidth: 3,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: BondlyTheme.darkTheme.textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

class BondlyErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const BondlyErrorWidget({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: BondlyTheme.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'Ups! Algo correu mal',
              style: BondlyTheme.darkTheme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: BondlyTheme.darkTheme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BondlyTheme.primary.withOpacity(0.1),
                  foregroundColor: BondlyTheme.primary,
                  side: const BorderSide(color: BondlyTheme.primary),
                ),
                child: const Text('Tentar Novamente'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class BondlyCard extends StatelessWidget {
  final Widget child;
  final double? padding;
  final VoidCallback? onTap;

  const BondlyCard({super.key, required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (onTap != null) onTap!();
      },
      child: Container(
        padding: EdgeInsets.all(padding ?? 20),
        decoration: BondlyTheme.glassDecoration(),
        child: child,
      ),
    );
  }
}

