import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../widgets/app_icon_widget.dart';
import 'pin_input_screen.dart';
import '../home/home_screen.dart';

/// 앱 잠금 해제 화면
///
/// 생체 인증 우선, 실패 시 PIN 입력으로 폴백
class UnlockScreen extends StatefulWidget {
  const UnlockScreen({super.key});

  @override
  State<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen> {
  final AuthService _authService = AuthService();
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    // 화면 로드 후 자동으로 생체 인증 시도
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attemptBiometricUnlock();
    });
  }

  Future<void> _attemptBiometricUnlock() async {
    if (_isAuthenticating) return;

    setState(() => _isAuthenticating = true);

    final biometricAvailable = await _authService.isBiometricAvailable();
    final biometricEnabled = await _authService.isBiometricEnabled();

    if (biometricAvailable && biometricEnabled) {
      final authenticated = await _authService.authenticateWithBiometric(
        reason: '메모르 앱을 잠금 해제하려면 인증이 필요합니다',
      );

      if (authenticated && mounted) {
        _navigateToHome();
        return;
      }
    }

    setState(() => _isAuthenticating = false);
  }

  void _showPinInput() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PinInputScreen(
          onSuccess: _navigateToHome,
        ),
      ),
    );
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacing6),
          child: Column(
            children: [
              // Spacer to push content to center
              const Spacer(flex: 2),

              // 앱 아이콘
              const AppIconWidget(size: 100),

              SizedBox(height: AppTheme.spacing6),

              // 앱 이름
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
              ),

              SizedBox(height: AppTheme.spacing2),

              // 잠금 상태
              Text(
                '잠금 해제',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),

              SizedBox(height: AppTheme.spacing8),

              // 잠금 해제 버튼 또는 로딩 인디케이터
              if (_isAuthenticating)
                CircularProgressIndicator(color: AppColors.primary)
              else
                Column(
                  children: [
                    // 생체 인증 버튼
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _attemptBiometricUnlock,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          minimumSize: const Size(double.infinity, 56),
                        ),
                        icon: const Icon(Icons.fingerprint, size: 28),
                        label: const Text(
                          '생체 인증으로 잠금 해제',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    SizedBox(height: AppTheme.spacing4),

                    // PIN 입력 버튼
                    TextButton(
                      onPressed: _showPinInput,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: Text(
                        'PIN으로 잠금 해제',
                        style:
                            Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: AppColors.primary,
                                ),
                      ),
                    ),
                  ],
                ),

              // Spacer to push footer to bottom
              const Spacer(flex: 3),

              // End-to-End Encrypted 푸터
              Container(
                padding: EdgeInsets.all(AppTheme.spacing3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shield,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: AppTheme.spacing2),
                    Text(
                      'End-to-End Encrypted',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppTheme.spacing3),
            ],
          ),
        ),
      ),
    );
  }
}
