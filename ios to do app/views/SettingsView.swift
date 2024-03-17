//
//  SettingsView.swift
//  ios to do app
//
//  Created by Cristi Conecini on 16.01.23.
//

import SwiftUI
/// The SettingsView allows a user to edit the selected theme, enable reminders when they are disabled, or log out from the currently signed in account.
struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var showEnableRemindersButton : Bool = false
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("tintColorHex") var tintColorHex: String = TINT_COLORS[0]
    
    
    /// Creates an instance with the given entityId.
    ///
    /// - Parameters:
    ///   - None
    init(){
        self.viewModel = SettingsViewModel()
    }
    
    func setAppIcon(tintColor: String, themePrefix: String) {
        Task {
            await RemindersWidgetAppIconUtil.setAppIcon(tintColor: tintColor, themePrefix: themePrefix)
        }
    }
    
    /// The structure of the view
    var body: some View {
        ZStack{
            Form {
                /// Accent color setting
                Section("Theme") {
                    Picker("Accent color", selection: $tintColorHex) {
                        ForEach(TINT_COLORS, id: \.self) { colorHex in
                            let tintColor = TintColor(colorHex: colorHex)
                            Text(tintColor.name).foregroundColor(tintColor.color)
                        }
                    }.onChange(of: $tintColorHex.wrappedValue, perform: { newState in
                        setAppIcon(tintColor: tintColorHex, themePrefix:  colorScheme == .dark ? "Dark" : "Light")
                    })
                    
                }
                /// Enabling notifications
                if viewModel.showEnableRemindersButton {
                    Section("Notifications"){
                        Button( action: viewModel.requestNotificationsPermission){
                            Label("Enable reminders", systemImage: "bell")
                        }
                    }
                }
                /// Log out button 
                Section{
                    Button("Log out", action: viewModel.signOut)
                        .foregroundColor(Color.red)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                }}
        }.navigationTitle("Settings")
        
    }
}
  
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
