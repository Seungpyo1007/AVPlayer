//
//  AppDelegate.swift
//  AVPlayer
//
//  Created by 홍승표 on 10/28/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Application Lifecycle
    
    /// 앱이 시작될 때 호출 - 초기 설정
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 앱 전역 설정 (예: 네트워크, 데이터베이스, 서드파티 SDK 초기화)
        return true
    }

    // MARK: - UISceneSession Lifecycle
    
    /// 새로운 Scene 세션이 생성될 때 호출
    func application(_ application: UIApplication,
                    configurationForConnecting connectingSceneSession: UISceneSession,
                    options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Scene 설정을 반환 (Info.plist의 Scene Configuration 사용)
        return UISceneConfiguration(name: "Default Configuration",
                                   sessionRole: connectingSceneSession.role)
    }
    
    /// Scene 세션이 삭제될 때 호출
//    func application(_ application: UIApplication,
//                    didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // 삭제된 Scene에 관련된 리소스 정리
//        // 앱이 실행 중이지 않을 때 삭제된 세션도 여기서 처리됨
//    }
}
