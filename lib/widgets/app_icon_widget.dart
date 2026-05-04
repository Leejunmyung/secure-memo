import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// 메모르 앱 아이콘
///
/// 메모 아이콘에 자물쇠 배지가 결합된 형태
class AppIconWidget extends StatelessWidget {
  final double size;
  final bool showContainer;

  const AppIconWidget({
    super.key,
    this.size = 120,
    this.showContainer = true,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = size * 0.53; // 메인 아이콘 크기 (64/120 비율)
    final lockSize = size * 0.25; // 자물쇠 크기
    final containerSize = size;

    final iconWidget = SizedBox(
      width: containerSize,
      height: containerSize,
      child: Stack(
        children: [
          // 메인 메모 아이콘
          Center(
            child: Icon(
              Icons.sticky_note_2_outlined,
              size: iconSize,
              color: AppColors.onPrimary,
            ),
          ),

          // 자물쇠 배지 (오른쪽 하단)
          Positioned(
            right: containerSize * 0.15,
            bottom: containerSize * 0.15,
            child: Container(
              padding: EdgeInsets.all(lockSize * 0.25),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.onPrimary,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.lock,
                size: lockSize,
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );

    if (!showContainer) {
      return iconWidget;
    }

    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(containerSize * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: iconWidget,
    );
  }
}
