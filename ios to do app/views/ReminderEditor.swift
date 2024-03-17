//
//  ReminderEditor.swift
//  ios to do app
//
//  Created by Cristi Conecini on 14.01.23.
//

import SwiftUI

/// A view for editing / creating a reminder
struct ReminderEditor: View {
    /// The environment presentation mode to control dismissing the view
    @Environment(\.presentationMode) var presentation
    /// The observable object `reminder` for the Reminder to be edited
    @ObservedObject var reminder: Reminder
    /// The completion handler to be called when the reminder is saved
    var onComplete: (Reminder) -> Void

    init(reminder: Reminder?, onComplete: @escaping (Reminder) -> Void) {
        self.reminder = reminder ?? Reminder(date: Date())
        self.onComplete = onComplete
    }

    /// Function to save the edited reminder
    func saveReminder() {
        onComplete(reminder)
        presentation.wrappedValue.dismiss()
    }

    var body: some View {
        VStack {
            Text("Add Reminder").font(.headline)
                DatePicker(selection: $reminder.date, in: Date()..., displayedComponents: [.date, .hourAndMinute]) {
                }.datePickerStyle(.graphical)
            Button("Save", action: saveReminder).buttonStyle(.automatic).padding()
        }
    }
}


struct ReminderEditor_Previews: PreviewProvider {
    static var previews: some View {
        ReminderEditor(reminder: nil, onComplete: { _ in })
    }
}
