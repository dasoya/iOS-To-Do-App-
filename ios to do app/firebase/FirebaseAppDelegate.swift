//
//  FirebaseAppDelegate.swift
//  ios to do app
//
//  Created by Cristi Conecini on 16.01.23.
//

import FirebaseCore
import Foundation
import SwiftUI

/// App delegate used for initialising Firebase and notification navigation
class FirebaseAppDelegate: NSObject, UIApplicationDelegate {
    weak var notificationManager: NotificationNavigationManager?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
    {
        FirebaseApp.configure()

        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void)
    {
        notificationManager?.pageToNavigateTo = "today"
        completionHandler()
    }
}
