import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../utils/constants.dart';
import 'security_settings_screen.dart';

/// 설정 메인 화면
///
/// 보안 설정, 앱 정보 등
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: AppTheme.spacing4),

              // 보안 섹션
              _buildSection(
                context,
                title: '보안',
                children: [
                  _buildListTile(
                    context,
                    icon: Icons.lock_outline,
                    title: '보안 설정',
                    subtitle: 'PIN, 생체 인증, 자동 잠금',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SecuritySettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: AppTheme.spacing4),

              // 앱 정보 섹션
              _buildSection(
                context,
                title: '앱 정보',
                children: [
                  _buildListTile(
                    context,
                    icon: Icons.info_outline,
                    title: '버전',
                    subtitle: AppConstants.appVersion,
                    onTap: null, // 클릭 불가
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.description_outlined,
                    title: '라이선스',
                    subtitle: '오픈소스 라이선스',
                    onTap: () {
                      showLicensePage(
                        context: context,
                        applicationName: AppConstants.appName,
                        applicationVersion: AppConstants.appVersion,
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: AppTheme.spacing8),

              // 보안 안내
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
                child: Container(
                  padding: EdgeInsets.all(AppTheme.spacing3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: AppTheme.spacing2),
                      Expanded(
                        child: Text(
                          '모든 데이터는 AES-256-GCM으로 암호화되어\n기기에만 저장됩니다. 네트워크 연결 없음.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 섹션 빌더
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacing4,
            vertical: AppTheme.spacing2,
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: AppTheme.spacing3),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  /// ListTile 빌더
  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
        size: 24,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w500,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
      ),
      trailing: onTap != null
          ? Icon(
              Icons.chevron_right,
              color: AppColors.onSurfaceVariant,
            )
          : null,
      onTap: onTap,
    );
  }
}
