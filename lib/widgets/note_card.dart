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
    // 날짜 포맷
    final dateFormat = DateFormat('yyyy.MM.dd HH:mm');
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 (타입 아이콘 + 즐겨찾기)
            Row(
              children: [
                // 타입 아이콘
                Text(
                  note.type.icon,
                  style: const TextStyle(fontSize: 20),
                ),
                SizedBox(width: AppTheme.spacing1),

                // 타입 이름
                Text(
                  note.type.displayName,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),

                const Spacer(),

                // 즐겨찾기 버튼
                if (onFavoriteTap != null)
                  IconButton(
                    icon: Icon(
                      note.isFavorite ? Icons.star : Icons.star_border,
                      color: note.isFavorite
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                      size: 20,
                    ),
                    onPressed: onFavoriteTap,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),

            SizedBox(height: AppTheme.spacing2),

            // 제목
            Text(
              note.title,
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: AppTheme.spacing2),

            // 암호화 배지 + 날짜
            Row(
              children: [
                // 암호화 배지
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing2,
                    vertical: AppTheme.spacing1 / 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: AppTheme.spacing1 / 2),
                      Text(
                        '암호화됨',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // 날짜
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
    );
  }
}
