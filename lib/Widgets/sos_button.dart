import 'dart:ui';
import 'package:flutter/material.dart';

class SosButton extends StatelessWidget {
  const SosButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.context,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
