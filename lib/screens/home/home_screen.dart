import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../utils/constants.dart';
import '../../providers/note_provider.dart';
import '../../models/note_type.dart';
import '../../models/encrypted_payload.dart';
import '../../widgets/note_card.dart';

/// 홈 화면 (메모 목록)
///
/// Phase 2: 메모 CRUD 기능 완전 구현
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        automaticallyImplyLeading: false,
        actions: [
          // 검색 버튼
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 검색 기능 구현 (Phase 2 후반)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('검색 기능은 곧 추가될 예정입니다'),
                ),
              );
            },
          ),
          // 설정 버튼
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: 설정 화면 구현 (Phase 4)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('설정 기능은 Phase 4에서 구현될 예정입니다'),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, child) {
          if (noteProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (noteProvider.notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_add_outlined,
                    size: 80,
                    color: AppColors.onSurfaceVariant,
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  Text(
                    '메모가 없습니다',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: AppTheme.spacing2),
                  Text(
                    '새 메모를 추가하려면\n아래 + 버튼을 눌러주세요',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: AppTheme.spacing2),
            itemCount: noteProvider.notes.length,
            itemBuilder: (context, index) {
              final note = noteProvider.notes[index];
              return NoteCard(
                note: note,
                onTap: () {
                  // TODO: 메모 상세/편집 화면으로 이동
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${note.title} 선택됨'),
                    ),
                  );
                },
                onFavoriteTap: () {
                  noteProvider.toggleFavorite(note.id);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteTypeSelector(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 메모 타입 선택 바텀시트
  void _showNoteTypeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusLarge * 2),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppTheme.spacing4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '새 메모 추가',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.onSurface,
                      ),
                ),
                SizedBox(height: AppTheme.spacing4),
                // 일반 메모
                _buildNoteTypeOption(
                  context,
                  type: NoteType.general,
                  onTap: () {
                    Navigator.pop(context);
                    _createQuickNote(context, NoteType.general);
                  },
                ),
                SizedBox(height: AppTheme.spacing2),
                // 계정 정보
                _buildNoteTypeOption(
                  context,
                  type: NoteType.account,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('계정 정보 입력은 Phase 3에서 구현될 예정입니다'),
                      ),
                    );
                  },
                ),
                SizedBox(height: AppTheme.spacing2),
                // 카드 정보
                _buildNoteTypeOption(
                  context,
                  type: NoteType.card,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('카드 정보 입력은 Phase 3에서 구현될 예정입니다'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 메모 타입 옵션 빌더
  Widget _buildNoteTypeOption(
    BuildContext context, {
    required NoteType type,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: EdgeInsets.all(AppTheme.spacing3),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Row(
          children: [
            Text(
              type.icon,
              style: const TextStyle(fontSize: 32),
            ),
            SizedBox(width: AppTheme.spacing3),
            Text(
              type.displayName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// 빠른 메모 생성 (일반 메모만 지원)
  ///
  /// Phase 2: 간단한 다이얼로그로 메모 생성
  /// Phase 3: 전용 편집 화면으로 이동
  void _createQuickNote(BuildContext context, NoteType type) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${type.icon} ${type.displayName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '제목',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              SizedBox(height: AppTheme.spacing2),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: '내용',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('제목을 입력하세요')),
                  );
                  return;
                }

                if (contentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('내용을 입력하세요')),
                  );
                  return;
                }

                // 메모 생성
                final provider = context.read<NoteProvider>();
                await provider.createNote(
                  title: titleController.text.trim(),
                  payload: EncryptedPayload.general(
                    contentController.text.trim(),
                  ),
                  type: type,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('메모가 생성되었습니다')),
                  );
                }
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }
}
