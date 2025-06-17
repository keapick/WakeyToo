//
//  AppDelegate.swift
//  Wakey
//
//  Created by echo on 12/8/24.
//

import UIKit
import WakeyLib

// silence Swift 6 concurrency error
#if !os(tvOS)
extension UIApplicationShortcutItem: @retroactive @unchecked Sendable { }
#endif

// UIKit code to handle quick actions, this isn't nicely supported by SwiftUI yet
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        let sceneConfiguration = UISceneConfiguration(name: "Custom Configuration", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = SceneDelegate.self
        return sceneConfiguration
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    #if !os(tvOS)
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem) async -> Bool {
        let name = shortcutItem.localizedTitle
        WakeOnLAN.wakeServerByName(name)
        return true
    }
    #endif
}
