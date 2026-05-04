import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../models/note.dart';
import '../../models/note_type.dart';
import '../../models/encrypted_payload.dart';
import '../../providers/note_provider.dart';

/// 일반 메모 편집 화면
///
/// 일반 텍스트 메모 생성/편집
class NoteEditorScreen extends StatefulWidget {
  final Note? note; // null이면 새 메모, 값이 있으면 편집 모드

  const NoteEditorScreen({
    super.key,
    this.note,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _categoryController = TextEditingController();
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
    _titleController.dispose();
    _contentController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  /// 기존 메모 로드 (복호화)
  Future<void> _loadNote() async {
    setState(() => _isLoadingContent = true);

    try {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      final payload = await noteProvider.decryptNote(widget.note!);

      setState(() {
        _titleController.text = widget.note!.title;
        _categoryController.text = widget.note!.category;
        _contentController.text = payload.content ?? '';
        _isLoadingContent = false;
      });
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

  /// 메모 저장
  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목을 입력하세요')),
      );
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내용을 입력하세요')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      final payload = EncryptedPayload.general(_contentController.text.trim());

      if (widget.note == null) {
        // 새 메모 생성
        await noteProvider.createNote(
          title: _titleController.text.trim(),
          payload: payload,
          type: NoteType.general,
          category: _categoryController.text.trim(),
        );
      } else {
        // 기존 메모 업데이트
        await noteProvider.updateNote(
          id: widget.note!.id,
          title: _titleController.text.trim(),
          payload: payload,
          category: _categoryController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.note == null ? '메모가 생성되었습니다' : '메모가 수정되었습니다'),
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
        setState(() => _isLoading = false);
      }
    }
  }

  /// 메모 삭제
  Future<void> _deleteNote() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('메모 삭제'),
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
              content: Text('메모가 삭제되었습니다'),
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
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: EdgeInsets.only(left: AppTheme.spacing2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chevron_left, color: AppColors.primary, size: 24),
                Text(
                  widget.note == null ? '취소' : '뒤로',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
        leadingWidth: 90,
        title: Text(
          widget.note == null ? '새 메모' : '메모 편집',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
        ),
        actions: [
          if (widget.note != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteNote,
              color: AppColors.error,
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
            Padding(
              padding: EdgeInsets.only(right: AppTheme.spacing3),
              child: ElevatedButton(
                onPressed: _saveNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing3,
                    vertical: AppTheme.spacing2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                child: const Text('저장'),
              ),
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
              child: Column(
                children: [
                  // Editor Area
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(AppTheme.spacing4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 제목 섹션
                          Text(
                            '제목',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                          ),
                          SizedBox(height: AppTheme.spacing2),
                          TextField(
                            controller: _titleController,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                            decoration: InputDecoration(
                              hintText: '메모 제목을 입력하세요',
                              hintStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                                  ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            maxLines: 1,
                          ),

                          SizedBox(height: AppTheme.spacing4),

                          // 카테고리 섹션
                          Text(
                            '카테고리',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                          ),
                          SizedBox(height: AppTheme.spacing2),
                          TextField(
                            controller: _categoryController,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.onSurface,
                                ),
                            decoration: InputDecoration(
                              hintText: '입력하지 않으면 \'일반\'',
                              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                                  ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            maxLines: 1,
                          ),
                          SizedBox(height: AppTheme.spacing2),
                          // 추천 카테고리 칩
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ['금융', '법률', '개인', '의료', '신분'].map((cat) {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _categoryController.text = cat;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _categoryController.text == cat
                                        ? AppColors.primary
                                        : AppColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    cat,
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: _categoryController.text == cat
                                              ? Colors.white
                                              : AppColors.onSurfaceVariant,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          SizedBox(height: AppTheme.spacing4),

                          // 내용 섹션
                          Text(
                            '내용',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                          ),
                          SizedBox(height: AppTheme.spacing2),
                          TextField(
                            controller: _contentController,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.onSurface,
                                  height: 1.6,
                                ),
                            decoration: InputDecoration(
                              hintText: '자유롭게 내용을 입력하세요...\n\n계정 정보, 카드 번호, 비밀번호 등 어떤 내용이든 안전하게 암호화됩니다.',
                              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                                  ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            maxLines: null,
                            minLines: 10,
                            keyboardType: TextInputType.multiline,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
