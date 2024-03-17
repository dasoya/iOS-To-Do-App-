//
//  TodoRow.swift
//  ios to do app
//
//  Created by Cristi Conecini on 28.01.23.
//

import Foundation
import SwiftUI

///Row item rendering a Todo. Supports EditMode
///- Parameters
///     - item: row data Binding
struct TodoRow: View {
    @Environment(\.editMode) var editMode
    
    @Binding var item: (String, Todo)
    public var onToggleCheckbox: (Bool) -> Void
    
    var body: some View {
        
        if editMode?.wrappedValue == EditMode.active {
            HStack{
                Text(item.1.task)
                Spacer()
            }
        }else{
            
            HStack{
                Checkbox(isChecked: $item.1.isCompleted){
                    self.onToggleCheckbox(item.1.isCompleted)
                }
                NavigationLink(destination: TodoDetail(entityId: item.0)){
                    HStack {
                        Text(item.1.task)
                        Text(item.1.priority.rawValue)
                            .font(.caption2)
                            .padding(.horizontal, 4)
                            .background(item.1.priority == .high ? .red : item.1.priority == .medium ? .orange : .yellow)
                            .cornerRadius(16)
                        Spacer()
                        
                    }
                }
            }
        }
    }
}

#if DEBUG

struct TodoRow_Mock: View{
    
    @State var item = ("", Todo())

    
    var body: some View{
        TodoRow(item: $item, onToggleCheckbox: {checked in
            
        })
    }
}

struct TodoRow_Previews: PreviewProvider {
    static var previews: some View{
       TodoRow_Mock()
    }
}

#endif
