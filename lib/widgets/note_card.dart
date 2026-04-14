import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_colors.dart';
import '../config/app_theme.dart';
import '../config/app_typography.dart';
import '../models/note.dart';
import '../models/note_type.dart';

/// 메모 카드 위젯
///
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
    // 날짜 포맷 (Renewal 스타일)
    final dateFormat = DateFormat('yyyy.MM.dd');
    final formattedDate = dateFormat.format(note.updatedAt);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: AppTheme.spacing2,
          horizontal: AppTheme.spacing4,
        ),
        padding: EdgeInsets.all(AppTheme.spacing3),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          // Stitch subtle shadow
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF29343A).withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 아이콘 프리픽스
            Container(
              padding: EdgeInsets.all(AppTheme.spacing2),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(
                Icons.lock,
                size: 20,
                color: AppColors.primary,
              ),
            ),

            SizedBox(width: AppTheme.spacing3),

            // 제목 + 날짜 컬럼
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    note.title,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: AppTheme.spacing1 / 2),

                  // 타입 + 날짜
                  Row(
                    children: [
                      Text(
                        note.type.displayName,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(width: AppTheme.spacing1),
                      Text(
                        '•',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(width: AppTheme.spacing1),
                      Text(
                        formattedDate,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 우측 영역 (즐겨찾기 + chevron)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 즐겨찾기 버튼
                if (onFavoriteTap != null && note.isFavorite)
                  Padding(
                    padding: EdgeInsets.only(right: AppTheme.spacing1),
                    child: Icon(
                      Icons.star,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),

                // Navigation 인디케이터
                Icon(
                  Icons.chevron_right,
                  size: 24,
                  color: AppColors.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
