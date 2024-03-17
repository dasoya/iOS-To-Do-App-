//
//  ProjectListView.swift
//  ios to do app
//
//  Created by Cristi Conecini on 24.01.23.
//

// ProjectListView.swift
// ios to do app
//
// Created by Cristi Conecini on 24.01.23.

import SwiftUI

/// The ProjectListView is a View that displays the list of to-dos for a given project, and allows you to perform various operations on the to-dos such as edit, add, and filter.
struct ProjectListView: View {
    /// The `tintColor` is the color used for various visual elements in the view, such as the add button.
    @Environment(\.tintColor) var tintColor
    
    /// The `editMode` environment determines whether the view is in editing mode or not.
    @Environment(\.editMode) var editMode
    
    /// The `viewModel` is an `ObservedObject` that contains the logic and data for the view.
    @ObservedObject var viewModel: ProjectListViewModel
    
    /// The `projectId` parameter specifies the ID of the project for which the list of to-dos is being displayed.
    var projectId: String
    
    /// The `showModal` state property determines whether the quick to-do creation modal is shown or not.
    @State private var showModal = false
    
    /// The `selectedFilter` state property determines the selected filter type for the list of to-dos.
    @State var selectedFilter: FilterType = .all
    
    /// The `init` method initializes the view with a given `projectId`.
    init(projectId: String){
        self.projectId = projectId
        viewModel = ProjectListViewModel(projectId: projectId)
    }
    
    /// The `body` property defines the content and layout of the view.
    var body: some View {
        VStack {
            List(selection: $viewModel.selection){
                Section{
                    header
                }
                Section{
                    ForEach($viewModel.todoList, id: \.0, editActions: .delete){
                        $item in
                            TodoRow(item: $item, onToggleCheckbox: {checked in
                                viewModel.saveTodo(entityId: item.0, todo: item.1)
                                viewModel.cloneRecurringTodoIfNecessary(entityId: item.0, todo: item.1)
                            }).onChange(of: item.1.isCompleted) { newValue in
                                
                            }
                    }
                    if showModal {
                        CreateQuickTodoView(projectId: self.projectId, show: $showModal)
                        
                    } else {
                        Label("Add Quick Todo", systemImage: "plus")
                            .onTapGesture {
                                showModal = true
                            }
                    }
                }
            }
            
            
            HStack {
                
                if editMode?.wrappedValue == EditMode.active {
                    Spacer()
                    /// The `VerticalLabelButton` is a button that displays a label and an icon vertically.
                    ///
                    /// - Parameters:
                    ///   - label: The text displayed on the button.
                    ///   - systemImage: The system image displayed on the button.
                    ///   - action: The action to perform when the button is tapped.
                    VerticalLabelButton("Project", systemImage: "folder.fill", action: {
                        viewModel.showMoveToProject = true
                    }).sheet(isPresented: $viewModel.showMoveToProject) {
                        SelectProjectView { projectId, _ in
                            viewModel.selectionMoveToProject(projectId: projectId)
                        }
                    }.disabled(viewModel.selection.count == 0)
                    Spacer()
                    VerticalLabelButton("Priority", systemImage: "exclamationmark.circle.fill") {
                        viewModel.showChangePriority = true
                    }.sheet(isPresented: $viewModel.showChangePriority) {
                        SelectPriorityView(priority: .medium) { newPriority in
                            viewModel.selectionChangePriority(newPriority: newPriority)
                        }
                    }.disabled(viewModel.selection.count == 0)
                    Spacer()
                    VerticalLabelButton("Due date", systemImage: "calendar.badge.clock") {
                        viewModel.showChangeDueDate = true
                    }.sheet(isPresented: $viewModel.showChangeDueDate) {
                        SelectDueDateView(date: Date()) { newDate in
                            viewModel.selectionChangeDueDate(newDueDate: newDate)
                        }
                    }.disabled(viewModel.selection.count == 0)
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
                        CreateTodoView(projectId: projectId)
                    } label: {
                        Text("Add")
                    }
                }
            }
            .padding(.horizontal,20)
        }.alert("Error: \(self.viewModel.error?.localizedDescription ?? "")", isPresented: $viewModel.showAlert) {
            Button("Ok", role: .cancel){
                self.viewModel.showAlert = false;
                self.viewModel.error = nil
            }
        }.toolbar {
            EditButton()
        }.navigationTitle(viewModel.project?.projectName ?? "Project")
    }
    
    var header: some View {
        VStack(alignment: .center) {
                Text("\(Int(viewModel.progress * 100))%")
                    .font(.system(size: 50, weight: .ultraLight, design: .rounded))
                Text("completed")
                    .font(.system(size: 18, design: .rounded))
            }.frame(width: UIScreen.main.bounds.width)
    }
    
}

struct ProjectListView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectListView(projectId: "")
    }
}
