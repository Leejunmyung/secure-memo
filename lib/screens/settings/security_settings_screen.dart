import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../services/auth_service.dart';
import '../onboarding/pin_setup_screen.dart';

/// 보안 설정 화면
///
/// PIN 변경, 생체 인증, 자동 잠금 설정
class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final AuthService _authService = AuthService();

  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      final available = await _authService.isBiometricAvailable();
      final enabled = await _authService.isBiometricEnabled();

      setState(() {
        _biometricAvailable = available;
        _biometricEnabled = enabled;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('설정 로드 실패: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    try {
      await _authService.setBiometricEnabled(value);
      setState(() {
        _biometricEnabled = value;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value ? '생체 인증이 활성화되었습니다' : '생체 인증이 비활성화되었습니다'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('생체 인증 설정 실패: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _changePIN() async {
    // PIN 변경을 위해 현재 PIN 먼저 확인
    final currentPin = await _showPinInputDialog('현재 PIN 입력');
    if (currentPin == null) return;

    // 현재 PIN 검증
    final isValid = await _authService.verifyPin(currentPin);
    if (!isValid) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('현재 PIN이 일치하지 않습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // 새 PIN 입력
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const PinSetupScreen(),
        ),
      );
    }
  }

  Future<String?> _showPinInputDialog(String title) async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: const Text('보안 설정'),
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('보안 설정'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppTheme.spacing4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PIN 설정
              _buildSection(
                context,
                title: 'PIN',
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.pin_outlined,
                      color: AppColors.primary,
                    ),
                    title: const Text('PIN 변경'),
                    subtitle: const Text('새로운 PIN으로 변경'),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppColors.onSurfaceVariant,
                    ),
                    onTap: _changePIN,
                  ),
                ],
              ),

              SizedBox(height: AppTheme.spacing4),

              // 생체 인증
              _buildSection(
                context,
                title: '생체 인증',
                children: [
                  SwitchListTile(
                    secondary: Icon(
                      Icons.fingerprint,
                      color: AppColors.primary,
                    ),
                    title: const Text('생체 인증 사용'),
                    subtitle: Text(
                      _biometricAvailable
                          ? 'Face ID 또는 지문으로 잠금 해제'
                          : '생체 인증을 사용할 수 없습니다',
                    ),
                    value: _biometricEnabled,
                    onChanged: _biometricAvailable ? _toggleBiometric : null,
                    activeColor: AppColors.primary,
                  ),
                ],
              ),

              SizedBox(height: AppTheme.spacing6),

              // 보안 안내
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
                      size: 20,
                      color: AppColors.error,
                    ),
                    SizedBox(width: AppTheme.spacing2),
                    Expanded(
                      child: Text(
                        'PIN을 잊어버리면 복구 키로만 복원할 수 있습니다.\nPIN을 안전하게 보관하세요.',
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

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: AppTheme.spacing2,
            bottom: AppTheme.spacing2,
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
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}
