import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../models/card_fields.dart';
import '../../models/encrypted_payload.dart';
import '../../models/note.dart';
import '../../models/note_type.dart';
import '../../providers/note_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/secure_text_field.dart';

/// 카드 정보 입력 화면
///
/// 신용/체크카드 정보 (카드 번호, 만료일, CVV 등) 입력
class CardFormScreen extends StatefulWidget {
  final Note? note; // null이면 새 메모, 값이 있으면 편집 모드

  const CardFormScreen({
    super.key,
    this.note,
  });

  @override
  State<CardFormScreen> createState() => _CardFormScreenState();
}

class _CardFormScreenState extends State<CardFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardholderNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingContent = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _loadNote();
    }
  }

  @override
  void dispose() {
    _cardholderNameController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _bankNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// 기존 메모 로드 (복호화)
  Future<void> _loadNote() async {
    setState(() => _isLoadingContent = true);

    try {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      final payload = await noteProvider.decryptNote(widget.note!);

      if (payload.fields != null) {
        final cardNumber = payload.fields!['cardNumber'] ?? '';
        setState(() {
          _cardholderNameController.text = payload.fields!['cardholderName'] ?? '';
          _cardNumberController.text = cardNumber;
          _expiryDateController.text = payload.fields!['expiryDate'] ?? '';
          _cvvController.text = payload.fields!['cvv'] ?? '';
          _bankNameController.text = payload.fields!['bankName'] ?? '';
          _notesController.text = payload.fields!['notes'] ?? '';
          _isLoadingContent = false;
        });
        // 카드 번호 포맷팅 적용
        if (cardNumber.isNotEmpty) {
          _formatCardNumber(cardNumber);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingContent = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('메모 로드 실패: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  /// 카드 번호 자동 포맷팅 (1234 5678 9012 3456)
  void _formatCardNumber(String value) {
    final cleaned = value.replaceAll(RegExp(r'\s+'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleaned[i]);
    }

    final formatted = buffer.toString();
    if (formatted != value) {
      _cardNumberController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  /// 만료일 자동 포맷팅 (MM/YY)
  void _formatExpiryDate(String value) {
    final cleaned = value.replaceAll('/', '');
    String formatted = cleaned;

    if (cleaned.length >= 2) {
      formatted = '${cleaned.substring(0, 2)}/${cleaned.substring(2)}';
    }

    if (formatted != value) {
      _expiryDateController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final cardFields = CardFields(
        cardholderName: _cardholderNameController.text.trim(),
        cardNumber: _cardNumberController.text.replaceAll(' ', ''),
        expiryDate: _expiryDateController.text.trim(),
        cvv: _cvvController.text.trim(),
        bankName: _bankNameController.text.trim().isEmpty ? null : _bankNameController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      final payload = EncryptedPayload.card(
        cardholderName: cardFields.cardholderName,
        cardNumber: cardFields.cardNumber,
        expiryDate: cardFields.expiryDate,
        cvv: cardFields.cvv,
        bankName: cardFields.bankName,
        notes: cardFields.notes,
      );

      final noteProvider = Provider.of<NoteProvider>(context, listen: false);

      if (widget.note == null) {
        // 새 메모 생성
        await noteProvider.createNote(
          title: cardFields.bankName ?? '카드 정보',
          payload: payload,
          type: NoteType.card,
        );
      } else {
        // 기존 메모 업데이트
        await noteProvider.updateNote(
          id: widget.note!.id,
          title: cardFields.bankName ?? '카드 정보',
          payload: payload,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.note == null ? '카드 정보가 저장되었습니다' : '카드 정보가 수정되었습니다'),
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

  /// 메모 삭제
  Future<void> _deleteCard() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('카드 정보 삭제'),
        content: const Text('정말 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final noteProvider = Provider.of<NoteProvider>(context, listen: false);
        await noteProvider.deleteNote(widget.note!.id);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('카드 정보가 삭제되었습니다'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('삭제 실패: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(widget.note == null ? '카드 정보' : '카드 정보 편집'),
        actions: [
          if (widget.note != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteCard,
              tooltip: '삭제',
            ),
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
              onPressed: _saveCard,
              tooltip: '저장',
            ),
        ],
      ),
      body: _isLoadingContent
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : SafeArea(
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
                        Icons.credit_card,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: AppTheme.spacing2),
                      Expanded(
                        child: Text(
                          '카드 정보는 AES-256-GCM으로 암호화되어 저장됩니다',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppTheme.spacing6),

                // 카드 소유자 (필수)
                SecureTextField(
                  controller: _cardholderNameController,
                  label: '카드 소유자',
                  hint: '예: 홍길동',
                  validator: (value) => Validators.required(value, '카드 소유자'),
                  keyboardType: TextInputType.name,
                ),

                SizedBox(height: AppTheme.spacing4),

                // 카드 번호 (필수)
                SecureTextField(
                  controller: _cardNumberController,
                  label: '카드 번호',
                  hint: '1234 5678 9012 3456',
                  keyboardType: TextInputType.number,
                  maxLength: 19, // 16자리 + 3개 공백
                  onChanged: _formatCardNumber,
                  validator: (value) {
                    final error = Validators.required(value, '카드 번호');
                    if (error != null) return error;

                    if (!Validators.isValidCardNumber(value!)) {
                      return '올바른 카드 번호가 아닙니다';
                    }
                    return null;
                  },
                ),

                SizedBox(height: AppTheme.spacing4),

                // 만료일 & CVV (같은 줄)
                Row(
                  children: [
                    // 만료일
                    Expanded(
                      child: SecureTextField(
                        controller: _expiryDateController,
                        label: '만료일',
                        hint: 'MM/YY',
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                        onChanged: _formatExpiryDate,
                        validator: (value) {
                          final error = Validators.required(value, '만료일');
                          if (error != null) return error;

                          if (!Validators.isValidExpiryDate(value!)) {
                            return '올바른 만료일이 아닙니다';
                          }
                          return null;
                        },
                      ),
                    ),

                    SizedBox(width: AppTheme.spacing3),

                    // CVV
                    Expanded(
                      child: SecureTextField(
                        controller: _cvvController,
                        label: 'CVV',
                        hint: '123',
                        obscureText: true,
                        showVisibilityToggle: true,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        validator: (value) {
                          final error = Validators.required(value, 'CVV');
                          if (error != null) return error;

                          if (!Validators.isValidCvv(value!)) {
                            return '3-4자리 숫자';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppTheme.spacing4),

                // 은행명 (선택)
                SecureTextField(
                  controller: _bankNameController,
                  label: '은행명 (선택)',
                  hint: '예: 신한은행, KB국민은행',
                  keyboardType: TextInputType.text,
                ),

                SizedBox(height: AppTheme.spacing4),

                // 추가 메모 (선택)
                SecureTextField(
                  controller: _notesController,
                  label: '추가 메모 (선택)',
                  hint: 'PIN, 결제 비밀번호 등',
                  maxLines: 4,
                  maxLength: 500,
                  keyboardType: TextInputType.multiline,
                  obscureText: true,
                  showVisibilityToggle: true,
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
                          '카드 정보는 매우 민감한 정보입니다.\n복구 키를 안전하게 보관하세요.',
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
