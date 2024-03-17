//
//  TagsInTodoView.swift
//  ios to do app
//
//  Created by Amit Kumar Shaw on 25.01.23.
//

import SwiftUI

/// View to list, select and create tags
struct TagsInTodoView: View {
    @Environment(\.tintColor) var tintColor
    
    private var todoId: String
    @ObservedObject var viewModel: TagViewModel
    @State private var showModal = false
    
    /// Creates an instance with the given todoId.
    ///
    /// - Parameters:
    ///   - todoId: Id of the todo to list the tags
    init(todoId: String) {
        self.todoId = todoId
        viewModel = TagViewModel()
    }
    
    var body: some View {
        VStack {
            if viewModel.error != nil {
                Text(viewModel.error?.localizedDescription ?? "")
            } else {
                
                List {
                    /// list the selected tags
                    Section(header: Text("Selected Tags")) {
                        ForEach($viewModel.tags, id: \.0) { $item in
                            if item.1!.todos.contains(todoId) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .onTapGesture {
                                            viewModel.removeTodo(id: item.0, todo: self.todoId)
                                        }.foregroundColor(tintColor)
                                    
                                    Text(item.1!.tag!)
                                    
                                    Spacer()
                                    Image(systemName: "trash")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .onTapGesture {
                                            viewModel.deleteTag(id: item.0)
                                        }.foregroundColor(.red)
                                }
                            }
                        }
                        if showModal {
                            CreateTagView(todoId: self.todoId, show: $showModal)
                            
                        } else {
                            Label("Add Tag", systemImage: "plus")
                                .foregroundColor(tintColor)
                                .onTapGesture {
                                    showModal = true
                                }
                        }
                    }
                    /// list the avaialbe tags which are not selected
                    Section(header: Text("Available Tags")) {
                        ForEach($viewModel.tags, id: \.0) { $item in
                            if !item.1!.todos.contains(todoId) {
                                HStack {
                                    Image(systemName: "circle")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .onTapGesture {
                                            viewModel.addTodo(id: item.0, todo: self.todoId)
                                        }.foregroundColor(tintColor)
                                    
                                    Text(item.1!.tag!)
                                    
                                    Spacer()
                                    Image(systemName: "trash")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .onTapGesture {
                                            viewModel.deleteTag(id: item.0)
                                        }.foregroundColor(.red)
                                }
                                
                            }
                        }
                        
                    }
                    
                }.navigationTitle("Tags")
                
            }
        }
    }
}

struct TagsInTodoView_Previews: PreviewProvider {
    static var previews: some View {
        TagsInTodoView(todoId: "FnrWh38iEZ32MNTm3904")
    }
}
