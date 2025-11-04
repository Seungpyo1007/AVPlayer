//
//  SceneDelegate.swift
//  AVPlayer
//
//  Created by 홍승표 on 10/28/25.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // MARK: - Scene 생명주기
    
    /// 앱이 처음 시작될 때 호출 - 초기 화면 설정
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }
        
        // 1. 윈도우 생성
        window = UIWindow(windowScene: windowScene)
        
        // 2. 초기 화면 설정 (SwiftUI)
        let lockView = PasscodeLockView(onUnlock: { [weak window] in
            let mainVC = ViewController()
            let nav = UINavigationController(rootViewController: mainVC)
            if let window = window {
                UIView.transition(with: window, duration: 0.25, options: .transitionCrossDissolve, animations: {
                    window.rootViewController = nav
                })
            }
        })
        let hosting = UIHostingController(rootView: lockView)
        // 3. 윈도우에 잠금 화면 설정 및 표시
        window?.rootViewController = hosting
        window?.makeKeyAndVisible()
    }
    
    /// Scene이 시스템에 의해 해제될 때 호출
    func sceneDidDisconnect(_ scene: UIScene) {
        // Scene이 백그라운드로 진입하거나 세션이 삭제될 때
        // 필요시 리소스 정리 코드 작성
    }
    
    /// Scene이 활성화될 때 호출 (포그라운드로 진입)
    func sceneDidBecomeActive(_ scene: UIScene) {
        // 일시 중지된 작업을 재시작하거나
        // 화면 갱신이 필요한 경우 처리
    }
    
    /// Scene이 비활성화될 때 호출 (곧 백그라운드로 진입)
    func sceneWillResignActive(_ scene: UIScene) {
        // 전화 수신 등 일시적 중단 상황에서 호출
        // 진행 중인 작업 일시 중지
    }
    
    /// Scene이 백그라운드에서 포그라운드로 전환될 때 호출
    func sceneWillEnterForeground(_ scene: UIScene) {
        // 백그라운드에서 변경된 내용을 되돌리거나
        // 화면 갱신 준비
    }
    
    /// Scene이 포그라운드에서 백그라운드로 전환될 때 호출
    func sceneDidEnterBackground(_ scene: UIScene) {
        // 데이터 저장, 리소스 해제
        // Scene 상태 정보 저장
    }
}

