import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../models/account_fields.dart';
import '../../models/encrypted_payload.dart';
import '../../models/note_type.dart';
import '../../providers/note_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/secure_text_field.dart';

/// 계정 정보 입력 화면
///
/// 서비스 계정 정보 (사용자명, 비밀번호 등) 입력
class AccountFormScreen extends StatefulWidget {
  const AccountFormScreen({super.key});

  @override
  State<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends State<AccountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serviceNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _serviceNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final accountFields = AccountFields(
        serviceName: _serviceNameController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        url: _urlController.text.trim().isEmpty ? null : _urlController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      final payload = EncryptedPayload.account(
        serviceName: accountFields.serviceName,
        username: accountFields.username,
        password: accountFields.password,
        url: accountFields.url,
        notes: accountFields.notes,
      );

      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      await noteProvider.createNote(
        title: accountFields.serviceName,
        payload: payload,
        type: NoteType.account,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('계정 정보가 저장되었습니다'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 실패: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('계정 정보'),
        actions: [
          if (_isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing3),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveAccount,
              tooltip: '저장',
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppTheme.spacing4),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 안내 메시지
                Container(
                  padding: EdgeInsets.all(AppTheme.spacing3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.1),
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
                          '모든 정보는 AES-256-GCM으로 암호화되어 저장됩니다',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppTheme.spacing6),

                // 서비스명 (필수)
                SecureTextField(
                  controller: _serviceNameController,
                  label: '서비스명',
                  hint: '예: Google, Naver, Github',
                  validator: (value) => Validators.required(value, '서비스명'),
                  keyboardType: TextInputType.text,
                ),

                SizedBox(height: AppTheme.spacing4),

                // 사용자명 (필수)
                SecureTextField(
                  controller: _usernameController,
                  label: '사용자명 또는 이메일',
                  hint: '예: user@example.com',
                  validator: (value) => Validators.required(value, '사용자명'),
                  keyboardType: TextInputType.emailAddress,
                ),

                SizedBox(height: AppTheme.spacing4),

                // 비밀번호 (필수)
                SecureTextField(
                  controller: _passwordController,
                  label: '비밀번호',
                  obscureText: true,
                  showVisibilityToggle: true,
                  showCopyButton: true,
                  validator: (value) => Validators.required(value, '비밀번호'),
                ),

                SizedBox(height: AppTheme.spacing4),

                // URL (선택)
                SecureTextField(
                  controller: _urlController,
                  label: 'URL (선택)',
                  hint: '예: https://example.com',
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      if (!Validators.isValidUrl(value.trim())) {
                        return '올바른 URL 형식이 아닙니다';
                      }
                    }
                    return null;
                  },
                ),

                SizedBox(height: AppTheme.spacing4),

                // 추가 메모 (선택)
                SecureTextField(
                  controller: _notesController,
                  label: '추가 메모 (선택)',
                  hint: '보안 질문, 복구 이메일 등',
                  maxLines: 4,
                  maxLength: 500,
                  keyboardType: TextInputType.multiline,
                ),

                SizedBox(height: AppTheme.spacing6),

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
                        Icons.lock_outline,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: AppTheme.spacing2),
                      Expanded(
                        child: Text(
                          '비밀번호 복사 시 1분 후 자동으로 클립보드가 삭제됩니다',
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
      ),
    );
  }
}
