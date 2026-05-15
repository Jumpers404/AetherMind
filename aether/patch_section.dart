import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

Widget _buildGlassSection({required String title, required Widget child, VoidCallback? onEdit, bool isHero = false}) {
  Widget innerContainer = Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: isHero 
      ? BoxDecoration(
          color: Colors.white.withOpacity(0.32),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.4),
              Colors.white.withOpacity(0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3C44).withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        )
      : BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.5)),
        ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title), // placeholder
            if (onEdit != null)
              GestureDetector(
                onTap: onEdit,
                child: const Icon(Icons.edit_rounded, size: 16, color: Color(0xFF4DA692)),
              ),
          ],
        ),
        const SizedBox(height: 20),
        child,
      ],
    ),
  );

  if (isHero) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: innerContainer,
      ),
    );
  }

  return innerContainer;
}
