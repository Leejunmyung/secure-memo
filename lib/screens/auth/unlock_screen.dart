import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
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
        reason: 'SecureKeep 앱을 잠금 해제하려면 인증이 필요합니다',
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
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppTheme.spacing6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 앱 아이콘
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusLarge * 3),
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    size: 56,
                    color: AppColors.onPrimary,
                  ),
                ),

                SizedBox(height: AppTheme.spacing6),

                // 앱 이름
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppColors.onSurface,
                      ),
                ),

                SizedBox(height: AppTheme.spacing2),

                // 잠금 상태 메시지
                Text(
                  '앱이 잠겨있습니다',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _attemptBiometricUnlock,
                          icon: const Icon(Icons.fingerprint),
                          label: const Text('생체 인증으로 잠금 해제'),
                        ),
                      ),

                      SizedBox(height: AppTheme.spacing3),

                      // PIN 입력 버튼
                      TextButton(
                        onPressed: _showPinInput,
                        child: Text(
                          'PIN으로 잠금 해제',
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: AppColors.primary,
                                  ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
