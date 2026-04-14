import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/recovery_key_service.dart';

/// 복구 키 재확인 화면
///
/// 생체 인증 또는 PIN 인증 후 복구 키 표시
class RecoveryKeyViewScreen extends StatefulWidget {
  const RecoveryKeyViewScreen({super.key});

  @override
  State<RecoveryKeyViewScreen> createState() => _RecoveryKeyViewScreenState();
}

class _RecoveryKeyViewScreenState extends State<RecoveryKeyViewScreen> {
  final AuthService _authService = AuthService();
  final RecoveryKeyService _recoveryService = RecoveryKeyService();

  bool _isAuthenticated = false;
  bool _isAuthenticating = true;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  /// 인증 수행 (생체 인증 → PIN 백업)
  Future<void> _authenticate() async {
    setState(() => _isAuthenticating = true);

    try {
      // 1. 생체 인증 시도
      final biometricAvailable = await _authService.isBiometricAvailable();
      final biometricEnabled = await _authService.isBiometricEnabled();

      if (biometricAvailable && biometricEnabled) {
        final authenticated = await _authService.authenticateWithBiometric(
          reason: '복구 키 확인을 위한 인증',
        );
        if (authenticated) {
          await _loadRecoveryKey();
          return;
        }
      }

      // 2. 생체 인증 실패 또는 불가능 → PIN 입력 요구
      if (mounted) {
        final pin = await _showPinInputDialog();
        if (pin == null) {
          // 취소 → 이전 화면으로
          Navigator.of(context).pop();
          return;
        }

        final isValid = await _authService.verifyPin(pin);
        if (isValid) {
          await _loadRecoveryKey();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PIN이 일치하지 않습니다'),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.of(context).pop();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('인증 실패: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  /// 복구 키 로드
  Future<void> _loadRecoveryKey() async {
    try {
      // 주의: 복구 키 자체는 저장되어 있지 않음
      // 이 화면은 사용자가 이미 백업한 복구 키를 재확인하는 용도
      // 실제로는 복구 키를 다시 생성할 수 없으므로, 저장된 해시만 확인 가능

      final hasRecoveryKey = await _recoveryService.hasRecoveryKey();

      if (!hasRecoveryKey) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('복구 키가 설정되지 않았습니다'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pop();
        }
        return;
      }

      setState(() {
        _isAuthenticated = true;
        _isAuthenticating = false;
        // 실제 복구 키는 표시할 수 없음 (보안상 저장되지 않음)
        // 사용자에게 백업한 복구 키를 안전하게 보관하고 있는지 확인만 가능
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('복구 키 로드 실패: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  /// PIN 입력 다이얼로그
  Future<String?> _showPinInputDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('PIN 입력'),
        content: TextField(
          controller: controller,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            labelText: 'PIN (6자리)',
            counterText: '',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.length == 6) {
                Navigator.pop(context, controller.text);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN은 6자리여야 합니다')),
                );
              }
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticating) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: const Text('복구 키 확인'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColors.primary,
              ),
              SizedBox(height: AppTheme.spacing4),
              Text(
                '인증 중...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isAuthenticated) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: const Text('복구 키 확인'),
        ),
        body: const Center(
          child: Text('인증되지 않았습니다'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('복구 키 확인'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacing4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 안내 메시지
              Container(
                padding: EdgeInsets.all(AppTheme.spacing3),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_outlined,
                      size: 24,
                      color: AppColors.error,
                    ),
                    SizedBox(width: AppTheme.spacing2),
                    Expanded(
                      child: Text(
                        '보안상 복구 키는 저장되지 않습니다.\n처음 생성 시 백업한 복구 키를 안전하게 보관하세요.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppTheme.spacing6),

              // 복구 키 상태
              Text(
                '복구 키 설정 완료',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),

              SizedBox(height: AppTheme.spacing2),

              Text(
                '복구 키는 처음 앱 설정 시 표시되었습니다.\n백업한 24단어를 안전하게 보관하고 있는지 확인하세요.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),

              const Spacer(),

              // 안내 사항
              Container(
                padding: EdgeInsets.all(AppTheme.spacing3),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: AppTheme.spacing2),
                        Text(
                          '복구 키 사용 방법',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppTheme.spacing2),
                    Text(
                      '• 기기를 분실하거나 앱을 재설치한 경우\n'
                      '• PIN을 잊어버린 경우\n'
                      '• 새 기기로 데이터를 복원하려는 경우\n\n'
                      '복구 키 24단어를 입력하여 모든 데이터를 복원할 수 있습니다.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
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
