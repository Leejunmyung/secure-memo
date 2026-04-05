package com.example.secure_keep

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

/**
 * SecureKeep 메인 액티비티
 *
 * 보안 기능:
 * - FLAG_SECURE: 스크린샷 및 화면 녹화 차단
 */
class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // 캡처 방지 활성화 (스크린샷, 화면 녹화 차단)
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
    }
}
