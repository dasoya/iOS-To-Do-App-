//
//  SearchView.swift
//  ios to do app
//
//  Created by Cristi Conecini on 25.01.23.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

/// View to display search results of matching Projects and Todos
struct SearchView: View {
    
    @Binding var searchText: String
    @ObservedObject var projectViewModel = ProjectViewModel()
    @ObservedObject var todoViewModel = TodoListViewModel()
    
    
    var body: some View {
            
        /// List all the matching projects
        Section(header: Text("Projects").font(.headline).foregroundColor(.accentColor)) {
            ForEach($projectViewModel.projects, id: \.0) { $item in
                
                if let _ = item.1!.projectName!.range(of: searchText, options: .caseInsensitive) {
                    NavigationLink(destination: ProjectListView(projectId: item.0)) {
                        ProjectListRow(project: (item.0, $item.1))
                    }
                }
            }.headerProminence(.standard)
        }.padding(.bottom)
            
        
        /// List all the matching Todos
        Section(header: Text("Todos").font(.headline).foregroundColor(.accentColor)) {
            
            
            ForEach($todoViewModel.todoList, id: \.0, editActions: .all){
                $item in
                if item.1.task.range(of: searchText, options: .caseInsensitive) != nil {
                        TodoRow(item: $item, onToggleCheckbox: {checked in
                            todoViewModel.saveTodo(entityId: item.0, todo: item.1)
                            todoViewModel.cloneRecurringTodoIfNecessary(entityId: item.0, todo: item.1)
                        }).onChange(of: item.1.isCompleted) { newValue in
                           
                        }
                }
            }
        }
    }
}
