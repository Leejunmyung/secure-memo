import Flutter
import UIKit

/**
 * SecureKeep AppDelegate
 *
 * 보안 기능:
 * - 백그라운드 진입 시 스냅샷 마스킹 (Blur 처리)
 */
@main
@objc class AppDelegate: FlutterAppDelegate {
  var blurView: UIVisualEffectView?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // 백그라운드 진입 시 스냅샷 마스킹
  override func applicationWillResignActive(_ application: UIApplication) {
    guard let window = self.window else { return }

    // Blur Effect 추가
    let blurEffect = UIBlurEffect(style: .light)
    let blurView = UIVisualEffectView(effect: blurEffect)
    blurView.frame = window.bounds
    blurView.tag = 9999  // 고유 태그로 나중에 찾기 위함
    window.addSubview(blurView)
    self.blurView = blurView
  }

  // 포그라운드 복귀 시 마스킹 제거
  override func applicationDidBecomeActive(_ application: UIApplication) {
    self.blurView?.removeFromSuperview()
    self.blurView = nil
  }
}
