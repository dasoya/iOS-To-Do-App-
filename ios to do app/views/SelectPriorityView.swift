//
//  SelectPriorityView.swift
//  ios to do app
//
//  Created by Cristi Conecini on 30.01.23.
//

import SwiftUI


///View which allows the of priority
///
///intended to be showed as a sheet
struct SelectPriorityView: View {
    @Environment(\.dismiss) var dismiss
    ///Selected Priority binding
    @State var priority: Priority
    
    ///Handler for save action
    /// - Parameters:
    ///    - newPriority: new value
    var onSelect: (_ newPriority: Priority) -> Void
    
    ///
    var body: some View {
        VStack{
            Picker(selection: $priority, label: Text("Priority")) {
                ForEach(Priority.allCases, id: \.self) { v in
                    Text(v.localizedName).tag(v)
                }
            }.pickerStyle(.wheel)
            Button("Save"){
                dismiss()
                onSelect(priority)
            }.padding()
        }
    }
}

struct SelectPriorityView_Previews: PreviewProvider {
    static var previews: some View {
        SelectPriorityView(priority: .medium) { newPriority in
        }
    }
}
