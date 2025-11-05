//
//  AppDelegate.swift
//  SilentBellApp
//
//  Created by Kritan Aryal on 11/4/25.
//

import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    // Called when app launches
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // ✅ Request push notification permission
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("❌ Push notification permission denied:", error?.localizedDescription ?? "unknown error")
            }
        }

        return true
    }

    // Called when device token is successfully registered
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("📱 Device Token: \(token)")

        if let savedToken = UserDefaults.standard.string(forKey: "deviceToken") {
            if savedToken == token {
                // Token unchanged → no need to send to backend
                print("✅ Device token unchanged, skipping backend update.")
                return
            } else {
                print("🔄 Device token changed, updating backend.")
            }
        } else {
            // No token saved → first registration
            print("🆕 No saved device token, sending to backend for the first time.")
        }

        // 2️⃣ Save the new token
        UserDefaults.standard.set(token, forKey: "deviceToken")

        // 3️⃣ Send to backend
        Task {
            do {
                try await APIService().registerDeviceToken(token: token)
                print("✅ Device token successfully registered with backend")
            } catch {
                UserDefaults.standard.removeObject(forKey: "deviceToken")
                print("❌ Failed to register device token:", error.localizedDescription)
            }
        }
    }

    // Called when registration fails
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Failed to register for notifications:", error.localizedDescription)
    }

    // Handle notification while app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}
