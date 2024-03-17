//
//  EnableRemindersModalView.swift
//  ios to do app
//
//  Created by Max on 21.01.23.
//

import Foundation
import SwiftUI

/// Shows a pretty modal to friendly ask the user for notification permissions. It gives either the option to directly enable the reminders or to jump to the settings setting of our app. This modal should only be visible once per app launch after a successfull login. It also offers an option to not showing the modal again after appearing three times.
struct EnableRemindersModalView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.tintColor) var tintColor
    @State private var didAskForNotifications : Bool = false
    @State private var appearanceCount : Int = 0
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                        
                    }.padding(30)
                    
                    Spacer()
                }
        
                Spacer()
                Image(systemName: "bell.fill").font(.system(size: 100)).foregroundColor(tintColor).padding()
                
                Text("Never miss a due date again!")
                    .font(.title2)
                    .multilineTextAlignment(TextAlignment.center)
                    .padding()
                
                Text("We highly recommend that you enable notificationns. Get notified when it's time to complete your tasks by enabling reminders for our app.")
                    .multilineTextAlignment(TextAlignment.center)
                    
                    .padding()
                
                Spacer()
                
                Button( action: {
                    if (didAskForNotifications) {
                        RemindersWidgetAppIconUtil.openSettings()
                    } else {
                        RemindersWidgetAppIconUtil.askForNotificationPermissions()
                    }
                    dismiss()
                }) {
                    Text(!didAskForNotifications ? "Enable reminders" : "Open settings")
                        .font(.headline)
                        .padding()
                        .background(tintColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    if (appearanceCount > 2) {
                        RemindersWidgetAppIconUtil.setDontShowRemindersModal()
                    }
                    dismiss()
                    
                }) {
                    Text(appearanceCount > 2 ? "Don't show again" : "Not now")
                        .font(.subheadline)
                        .padding()
                }
            }.padding(10)

            

        }.onAppear {
            appearanceCount = RemindersWidgetAppIconUtil.getReminderModalAppearanceCount()
            didAskForNotifications = RemindersWidgetAppIconUtil.didAskForNotificationPermissions()
            RemindersWidgetAppIconUtil.incrementReminderModalAppearanceCount()
        }
    }
}

struct EnableRemindersModalView_Previews: PreviewProvider {
    static var previews: some View {
        EnableRemindersModalView()
    }
}
