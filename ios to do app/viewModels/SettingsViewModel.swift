//
//  SettingsViewModel.swift
//  ios to do app
//
//  Created by Cristi Conecini on 16.01.23.
//

import Foundation
import FirebaseAuth
import SwiftUI
import Combine


///View model for SettingsView
class SettingsViewModel: ObservableObject {
    @Published var error: Error? = nil
    @Published var showEnableRemindersButton: Bool = false
    private var firAuth = Auth.auth()
    private var cancelables: [AnyCancellable] = []
    

    init(){
        RemindersWidgetAppIconUtil.hasPermissions { hasPermission in
            self.showEnableRemindersButton = !hasPermission
        }
    }
    
    ///sign current user out
    func signOut(){
        do {
            try firAuth.signOut()
        } catch {
            print("Error signing out", error)
            self.error = error
        }
    }
    
    ///request permision for push notification
    func requestNotificationsPermission(){
        if (RemindersWidgetAppIconUtil.didAskForNotificationPermissions()) {
            RemindersWidgetAppIconUtil.openSettings()
        } else {
            RemindersWidgetAppIconUtil.askForNotificationPermissions()
        }
    }
    
}
