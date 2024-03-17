//
//  TodoView.swift
//  ios to do app
//
//  Created by Shivam Singh Rajput on 10.01.23.
//

import Foundation
import SwiftUI



/// The UpcomingView displays all upcoming todos for the current week, grouped by day of the week.
struct UpcomingView: View {
    @ObservedObject var viewModel = UpcomingViewModel()
    /// Color from he color setting
    @Environment(\.tintColor) var tintColor
    @Environment(\.editMode) var editMode
    
    /// The structure of the view
    var body: some View {
        VStack {
            List(selection: $viewModel.selection) {
            /// Header
            Section{
                header
            }
            /// Todo List
               Section{
                   ForEach($viewModel.todoList, id: \.0) { $item in
                       TodoRow(item: $item, onToggleCheckbox: {checked in
                           viewModel.saveTodo(entityId: item.0, todo: item.1)
                           viewModel.cloneRecurringTodoIfNecessary(entityId: item.0, todo: item.1)
                       }).onChange(of: item.1.isCompleted) { newValue in
                           
                       }
                   }
                   .onDelete { indexSet in
                       viewModel.todoList.remove(atOffsets: indexSet)
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
        }.navigationTitle("Upcoming").onAppear {
            UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(tintColor)
            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        }
    }
    
    /// Header 
    var header: some View {
        VStack(alignment: .center) {
            /// Complete Process percent
            Text("\(Int(viewModel.progress * 100))%")
                .font(.system(size: 50, weight: .ultraLight, design: .rounded))
            Text("completed")
                .font(.system(size: 18, design: .rounded))
            /// Picker one day of the week
            Picker(selection: $viewModel.selectedWeekday) {
                ForEach(WEEKDAYS.indices, id: \.self) { index in
                    Text(WEEKDAYS[index].prefix(3))
                }
            } label: {
                EmptyView()
            }.pickerStyle(.segmented).padding(.horizontal,30)
        }.frame(width: UIScreen.main.bounds.width)
        
    }
    
    /// Bottom
    var bottomBar: some View {
        HStack {
            /// Collection edit
            if editMode?.wrappedValue == .active{
                /// Project move
                Spacer()
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
            }else{
                /// Picker of the filter of completing
                Picker(selection: $viewModel.filter, label: Text("Filter"), content: {
                    ForEach(FilterType.allCases, id: \.self) { v in
                        Text(v.localizedName).tag(v)
                    }
                })
                
                Spacer()
                /// Add button
                NavigationLink {
                    CreateTodoView()
                } label: {
                    Text("Add")
                    
                }
            }
        }.padding(.horizontal, 20)
    }
}

struct UpcomingView_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingView()
    }
}

