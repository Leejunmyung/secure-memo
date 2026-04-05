import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_keep/main.dart';

/// SecureKeep 앱 위젯 테스트
void main() {
  testWidgets('SecureKeep app smoke test', (WidgetTester tester) async {
    // 앱 빌드
    await tester.pumpWidget(const SecureKeepApp());

    // 스플래시 화면 확인
    expect(find.text('SecureKeep'), findsOneWidget);

    // 로딩 인디케이터 확인
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
