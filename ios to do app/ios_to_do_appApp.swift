//
//  ios_to_do_appApp.swift
//  ios to do app
//
//  Created by Cristi Conecini on 04.01.23.
//

import SwiftUI
import FirebaseCore
import Combine

@main
struct ios_to_do_appApp: App {
    
    let persistenceController = PersistenceController.shared
    let notificationNavigationManager = NotificationNavigationManager()
    @UIApplicationDelegateAdaptor(FirebaseAppDelegate.self) var delegate
    @AppStorage("tintColorHex") var tintColorHex = TINT_COLORS[0]
    @State private var showEnableRemindersModal : Bool = false
    
    
    
    func schedule(tintColor: String) {
        Task {
            await RemindersWidgetAppIconUtil.scheduleRemindersAndWidgetTimeline(tintColor: tintColor)
        }
    }
    
    func setAppIcon(tintColor: String) {
        Task {
            await RemindersWidgetAppIconUtil.setAppIcon(tintColor: tintColor, themePrefix: UITraitCollection.current.userInterfaceStyle.rawValue == UIUserInterfaceStyle(.dark).rawValue ? "Dark" : "Light")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(tintColor: Color(hex: tintColorHex))
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(\.tintColor, Color(hex: tintColorHex))
                .environmentObject(notificationNavigationManager)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    setAppIcon(tintColor: tintColorHex)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    schedule(tintColor: tintColorHex)
                }
                .onAppear {
                    RemindersWidgetAppIconUtil.hasPermissions(completion: { hasPermissions in
                        if !hasPermissions, !RemindersWidgetAppIconUtil.getDontShowRemindersModal() {
                            self.showEnableRemindersModal = true
                        }
                    })
                    
                    delegate.notificationManager = notificationNavigationManager
                }
            
                .fullScreenCover(isPresented: $showEnableRemindersModal) {
                    EnableRemindersModalView().tint(Color(hex: tintColorHex)).environment(\.tintColor, Color(hex: tintColorHex))
                }
        
                
        }
    }
}
