import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/app_icon_widget.dart';
import 'pin_setup_screen.dart';

/// 첫 실행 환영 화면
///
/// SecureKeep 앱의 첫 화면으로, 앱 소개 및 시작 버튼 제공
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacing6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // 앱 아이콘
              const AppIconWidget(size: 120),

              SizedBox(height: AppTheme.spacing6),

              // 환영 메시지
              Text(
                AppConstants.welcomeMessage,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppColors.onSurface,
                    ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: AppTheme.spacing3),

              // 부제목
              Text(
                AppConstants.welcomeSubtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // 시작 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const PinSetupScreen(),
                      ),
                    );
                  },
                  child: const Text('시작하기'),
                ),
              ),

              SizedBox(height: AppTheme.spacing3),

              // 보안 안내
              Container(
                padding: EdgeInsets.all(AppTheme.spacing3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: AppTheme.spacing2),
                    Expanded(
                      child: Text(
                        '모든 데이터는 기기에만 저장됩니다.\n네트워크 연결이 필요하지 않습니다.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
