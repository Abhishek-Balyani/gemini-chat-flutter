import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class CustomAvatar extends StatelessWidget {
  final bool isUser;
  final double size;

  const CustomAvatar({
    super.key,
    required this.isUser,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    if (isUser) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1),
        ),
        child: Icon(
          Icons.person,
          size: size * 0.6,
          color: AppColors.primary,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.auto_awesome,
        size: size * 0.55,
        color: Colors.white,
      ),
    );
  }
}
