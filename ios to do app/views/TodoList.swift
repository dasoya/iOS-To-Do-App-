//
//  TodoList.swift
//  ios to do app
//
//  Created by Cristi Conecini on 17.01.23.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth


/// View that is actually only used by the TodayView to show the list of todos due for today
struct TodoList: View {
    
    @ObservedObject var viewModel = TodoListViewModel()
    @State var projectId : String = ""
    
    
    init(_ dateFilter: Date? = nil,_ filter: FilterType? = nil,_ projectId : String? = nil){
        
        viewModel.dateFilter = dateFilter
        viewModel.filter = filter ?? .all
       
        if projectId != nil {
            
            self.projectId = projectId!
            viewModel.projectId = projectId!
       
        }
        
        viewModel.filter = filter ?? .all
        
    }
        
    
    var body: some View {
        List{
            
            ForEach($viewModel.todoList, id: \.0, editActions: .all){
                $item in
                NavigationLink(destination: TodoDetail(entityId: item.0)){
                    HStack {
                        Text(item.1.task)
                        Spacer()
                        Button(action: {}) {
                            Checkbox(isChecked: ($item.1.isCompleted), onToggle: {
                                viewModel.saveTodo(entityId: item.0, todo: item.1)
                                viewModel.cloneRecurringTodoIfNecessary(entityId: item.0, todo: item.1)
                            })
                        }
                        
                    }
                }
            }
        }
        .overlay(content: {if viewModel.todoList.isEmpty {
            VStack{
                Text("No todos created yet")
                NavigationLink {
                    CreateTodoView(projectId : self.projectId)
                } label: {
                    Label("New Todo", systemImage: "plus")
                }.buttonStyle(.bordered)
            }
        }})
            
        
    }
}

struct TodoList_Previews: PreviewProvider {
    static var previews: some View {
        TodoList()
    }
}
