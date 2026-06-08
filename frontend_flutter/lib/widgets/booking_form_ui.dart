import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

/// Shared polished UI for booking, auth, and onboarding flows.
class BookingFormUi {
  static PreferredSizeWidget appBar(BuildContext context, String title) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: AppColors.primary),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }

  static Widget gradientHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    List<Color>? colors,
  }) {
    final gradient = colors ??
        const [AppColors.primary, AppColors.primaryContainer];

    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.paddingBase),
      padding: const EdgeInsets.all(AppStyles.paddingLarge),
      decoration: AppDecorations.gradientCard(colors: gradient),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget sectionCard({
    required String title,
    required Widget child,
    String? step,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.paddingBase),
      padding: const EdgeInsets.all(AppStyles.paddingLarge),
      decoration: AppDecorations.elevatedCard(radius: AppStyles.radiusXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step != null ? '$step. $title' : title,
            style: AppStyles.headlineSmall.copyWith(fontSize: 16),
          ),
          const SizedBox(height: AppStyles.paddingMedium),
          child,
        ],
      ),
    );
  }

  static InputDecoration fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
        borderSide: const BorderSide(color: AppColors.surfaceContainerHigh),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
        borderSide: const BorderSide(color: AppColors.surfaceContainerHigh),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  static ButtonStyle primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
    );
  }

  static Widget authHero({
    required String title,
    required String subtitle,
    IconData icon = Icons.cleaning_services_rounded,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
