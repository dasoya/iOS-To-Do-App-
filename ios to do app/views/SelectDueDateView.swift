//
//  SelectDueDateView.swift
//  ios to do app
//
//  Created by Cristi Conecini on 30.01.23.
//

import SwiftUI

///View which allows the selection of a due date
struct SelectDueDateView: View {
    @Environment(\.dismiss) var dismiss
    ///Due date
    @State var date: Date
    ///Selection handler
    /// - Parameters:
    ///  - newDate: changed value
    var onSelect: (_ newDate: Date) -> Void
    
    var body: some View {
        VStack {
            Text("Set due date").font(.headline)
                DatePicker(selection: $date, in: Date()..., displayedComponents: [.date, .hourAndMinute]) {
                }.datePickerStyle(.graphical)
            Button("Save", action: {
                dismiss()
                onSelect(date)
            }).buttonStyle(.automatic).padding()
        }
    }
}

struct SelectDueDateView_Previews: PreviewProvider {
    static var previews: some View {
        SelectDueDateView(date: Date()) { newDate in
        }
    }
}
