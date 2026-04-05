import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_theme.dart';
import '../config/app_typography.dart';

/// 복구 키 그리드 위젯
///
/// 24개 단어를 4x6 그리드로 표시
class RecoveryKeyGrid extends StatelessWidget {
  final List<String> words;
  final bool selectable;

  const RecoveryKeyGrid({
    super.key,
    required this.words,
    this.selectable = false,
  });

  @override
  Widget build(BuildContext context) {
    if (words.length != 24) {
      return const Center(
        child: Text('복구 키는 24개 단어여야 합니다'),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2열
        childAspectRatio: 3.5, // 가로:세로 비율
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 24,
      itemBuilder: (context, index) {
        return _buildWordCell(context, index + 1, words[index]);
      },
    );
  }

  Widget _buildWordCell(BuildContext context, int number, String word) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacing2,
        vertical: AppTheme.spacing2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Row(
        children: [
          // 번호
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(width: AppTheme.spacing2),

          // 단어
          Expanded(
            child: SelectableText(
              word,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w500,
              ),
              enableInteractiveSelection: selectable,
            ),
          ),
        ],
      ),
    );
  }
}
