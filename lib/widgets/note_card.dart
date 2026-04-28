import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_colors.dart';
import '../config/app_theme.dart';
import '../config/app_typography.dart';
import '../models/note.dart';
import '../models/note_type.dart';

/// 메모 카드 위젯
///
/// Toss 스타일 디자인 적용
/// 메모 목록에서 각 메모를 표시하는 카드
class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onDeleteTap;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.onFavoriteTap,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    // 날짜 포맷
    final dateFormat = DateFormat('yyyy.MM.dd');
    final formattedDate = dateFormat.format(note.updatedAt);

    // 카테고리 색상 가져오기
    final categoryColors = AppColors.getCategoryColors(note.category);
    final categoryBg = categoryColors['bg']!;
    final categoryText = categoryColors['text']!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: AppTheme.spacing2 / 2,
          horizontal: AppTheme.spacing4,
        ),
        padding: EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge), // 28px
          // Toss 스타일 섬세한 그림자
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withValues(alpha: 0.055),
              blurRadius: 16,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: const Color(0xFF000000).withValues(alpha: 0.04),
              blurRadius: 0,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더: 카테고리 badge + 아이콘
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 카테고리 badge
                Container(
                  height: 22,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: categoryBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      note.category,
                      style: AppTypography.categoryTag.copyWith(
                        color: categoryText,
                      ),
                    ),
                  ),
                ),

                // 타입 아이콘 (우측 상단)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Icon(
                      _getIconForType(note.type),
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),

            // 제목
            Text(
              note.title,
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.onSurface,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 6),

            // 날짜
            Text(
              formattedDate,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.onSurfaceTertiary, // t3
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 메모 타입별 아이콘 반환
  IconData _getIconForType(NoteType type) {
    switch (type) {
      case NoteType.general:
        return Icons.note;
      case NoteType.account:
        return Icons.person;
      case NoteType.card:
        return Icons.credit_card;
    }
  }
}
