//
//  TodayView.swift
//  ios to do app
//
//  Created by Cristi Conecini on 25.01.23.
//

import SwiftUI
/// Displays all todos that are due for today.
struct TodayView: View {
    
    @Environment(\.editMode) var editMode
    @ObservedObject var viewModel: TodayViewModel
    
    /// Creates an instance with the given entityId.
    ///
    /// - Parameters:
    ///   - None
    init(){
        self.viewModel = TodayViewModel()
    }
    /// The structure of the view
    var body: some View {
        VStack {
            List(selection: $viewModel.selection){
                /// Header 
                Section{
                    header
                }
                /// Todo List
                Section(){
                    if viewModel.todoList.isEmpty {
                        emptyView()
                    }else {
                        ForEach($viewModel.todoList, id: \.0, editActions: .delete){
                            $item in
                            TodoRow(item: $item, onToggleCheckbox: {checked in
                                viewModel.saveTodo(entityId: item.0, todo: item.1)
                                viewModel.cloneRecurringTodoIfNecessary(entityId: item.0, todo: item.1)
                            }).onChange(of: item.1.isCompleted) { newValue in
                                
                            }
                        }.onDelete(perform: viewModel.deleteSelection)
                    }
                }
            }.listStyle(.insetGrouped)
            /// Bottom
            bottomBar
            
        }.alert("Error: \(self.viewModel.error?.localizedDescription ?? "")", isPresented: $viewModel.showAlert) {
            Button("Ok", role: .cancel){
                self.viewModel.showAlert = false;
                self.viewModel.error = nil
            }
        }.toolbar {
            EditButton()
        }.navigationTitle("Today")
    }
    
    var bottomBar: some View {
        HStack {
            /// Collection edit
            if(editMode?.wrappedValue == EditMode.active){
                Spacer()
                /// Project move
                VerticalLabelButton("Project", systemImage: "folder.fill", action: {
                    viewModel.showMoveToProject = true
                }).sheet(isPresented: $viewModel.showMoveToProject) {
                    SelectProjectView { projectId, _ in
                        viewModel.selectionMoveToProject(projectId: projectId)
                    }
                }
                /// Priority change
                Spacer()
                VerticalLabelButton("Priority", systemImage: "exclamationmark.circle.fill") {
                    viewModel.showChangePriority = true
                }.sheet(isPresented: $viewModel.showChangePriority) {
                    SelectPriorityView(priority: .medium) { newPriority in
                        viewModel.selectionChangePriority(newPriority: newPriority)
                    }
                }
                /// Due Date change
                Spacer()
                VerticalLabelButton("Due date", systemImage: "calendar.badge.clock") {
                    viewModel.showChangeDueDate = true
                }.sheet(isPresented: $viewModel.showChangeDueDate) {
                    SelectDueDateView(date: Date()) { newDate in
                        viewModel.selectionChangeDueDate(newDueDate: newDate)
                    }
                }
                Spacer()
                

            } else {
                
                Picker(selection: $viewModel.filter, label: Text("Filter"), content: {
                    ForEach(FilterType.allCases, id: \.self) { v in
                        Text(v.localizedName).tag(v)
                    }
                }).onChange(of: viewModel.filter) { newFilter in
                    viewModel.loadList(filter: newFilter)
                }
                Spacer()
                NavigationLink {
                    CreateTodoView()
                } label: {
                    Text("Add")
                }
            }
        }.padding(.horizontal, 20)
    }
    /// Header 
    var header: some View {
        VStack(alignment: .center) {
            /// Complete Process percent
            Text("\(Int(viewModel.progress * 100))%")
                .font(.system(size: 50, weight: .ultraLight, design: .rounded))
            Text("completed")
                .font(.system(size: 18, design: .rounded)).textCase(.uppercase)
        }
        .frame(width: UIScreen.main.bounds.width)
    }
    /// Condition that the Todo List is empty 
    func emptyView()-> AnyView {
        
        if viewModel.todoList.isEmpty {
                switch(viewModel.filter){
                case .all: return AnyView(VStack{
                    
                    NavigationLink {
                        CreateTodoView()
                    } label: {
                        Label("New Todo", systemImage: "plus")
                    }.buttonStyle(.bordered)
                })
                case .incomplete: return AnyView(Text("No incomplete todos"))
                case .completed: return AnyView(Text("No completed todos"))
                }
        }
        return AnyView(EmptyView())
    }
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView()
    }
}


