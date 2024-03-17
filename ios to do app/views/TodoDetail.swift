//
//  TodoDetail.swift
//  ios to do app
//
//  Created by Amit Kumar Shaw on 16.01.23.
//

import Combine
import SwiftUI

/// View to display all the details of a todo
struct TodoDetail: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(\.tintColor) var tintColor
    
    private var entityId: String
    @ObservedObject var viewModel: TodoEditorViewModel
    @ObservedObject var tagViewModel = TagViewModel()
    @State private var showBeforeDueDatePicker = false
    
    /// Creates an instance with the given entityId.
    ///
    /// - Parameters:
    ///   - entityId: Id of the todo to list the details
    init(entityId: String) {
        self.entityId = entityId
        viewModel = TodoEditorViewModel(id: entityId)
    }
    
    var body: some View {
        VStack {
            if viewModel.error != nil {
                Text(viewModel.error?.localizedDescription ?? "")
            } else {
                List {
                    /// show basic information
                    Section {
                        TextField("Task Name", text: $viewModel.todo.task)
                        HStack{
                            Text("Project")
                            Spacer()
                            Button(action: {viewModel.showProjectSelector = true}){
                                Text(viewModel.project?.projectName ?? "None")
                            }.sheet(isPresented: $viewModel.showProjectSelector) {
                                SelectProjectView { projectId, project in
                                    viewModel.todo.projectId = projectId
                                    viewModel.project = project
                                }
                            }
                        }
                        TextEditor(text: $viewModel.todo.description)
                    }
                    
                    /// show flashcards and a button to add flashcards
                    Section{
                        NavigationLink(destination: FlashcardView(viewModel: viewModel)){
                            HStack {
                                Text("All Flashcards")
                                Spacer()
                                Text("\(viewModel.flashcards.count) Cards")
                            }
                        }
                        Button(action: viewModel.toggleFlashcardEditor) {
                            Label("Add Flashcard", systemImage: "plus")
                        }.sheet(isPresented: $viewModel.showFlashcardEditor) {
                            FlashcardEditor(viewModel: viewModel)
                        }
                    }
                    
                    /// show the date and time of the todo
                    Section {
                        if dynamicTypeSize > DynamicTypeSize.medium {
                            VStack(alignment: .leading){
                                Text("Start Date")
                                DatePicker(selection: $viewModel.todo.startDate, in: Date()..., displayedComponents: [.date, .hourAndMinute]) {
                                    
                                }
                            }
                            VStack(alignment: .leading){
                                Text("Due Date")
                                DatePicker(selection: $viewModel.todo.dueDate, in: viewModel.todo.startDate..., displayedComponents: [.date, .hourAndMinute]) {
                                    
                                }
                            }
                        } else {
                            HStack{
                                Text("Start Date")
                                DatePicker(selection: $viewModel.todo.startDate, in: Date()..., displayedComponents: [.date, .hourAndMinute]) {

                                }
                            }
                            HStack{
                                Text("Due Date")
                                DatePicker(selection: $viewModel.todo.dueDate, in: viewModel.todo.startDate..., displayedComponents: [.date, .hourAndMinute]) {

                                }
                            }
                        }
                        Picker(selection: $viewModel.todo.recurring, label: Text("Recurring")) {
                            ForEach(Recurring.allCases, id: \.self) { v in
                                Text(v.localizedName).tag(v)
                            }
                        }
                    }
                    
                    /// Priority and Tags
                    Section {
                        Picker(selection: $viewModel.todo.priority, label: Text("Priority")) {
                            ForEach(Priority.allCases, id: \.self) { v in
                                Text(v.localizedName).tag(v)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                                        
                        NavigationLink(destination: TagsInTodoView(todoId: entityId)){
                            HStack {
                                Text("Tags")
                                Spacer()
                                Text("\(tagViewModel.tagCount(todo: entityId)) Tags")
                            }
                        }
                    }
                    
                    /// Reminders list
                    Section {
                        Button(action: {
                            if viewModel.todo.reminderBeforeDueDate < 0 {
                                viewModel.todo.reminderBeforeDueDate = -1 * viewModel.todo.reminderBeforeDueDate
                            }
                            self.showBeforeDueDatePicker = true
                        }) {
                            Label("\(RemindersWidgetAppIconUtil.getRemindMeBeforeDueDateDescription(minutes: viewModel.todo.reminderBeforeDueDate)) before due date", systemImage: viewModel.todo.reminderBeforeDueDate < 0 ? "bell.slash" : "bell").strikethrough(viewModel.todo.reminderBeforeDueDate < 0).swipeActions {
                                Button {
                                    viewModel.muteDefaultReminder()
                                } label: {
                                    Label("Mute", systemImage: viewModel.todo.reminderBeforeDueDate < 0 ? "bell.fill" : "bell.slash.fill")
                                }.tint(.indigo)
                            }
                                        
                        }.sheet(isPresented: $showBeforeDueDatePicker) {
                            RemindMeBeforeDueDatePicker(reminderBeforeDueDate: $viewModel.todo.reminderBeforeDueDate, isPresented: $showBeforeDueDatePicker).presentationDetents([.medium])
                        }
                                    
                        ForEach($viewModel.reminderList, id: \.id) {
                            reminder in
                            Label(reminderDateFormatter.string(from: reminder.date.wrappedValue), systemImage: "bell")
                        }.onDelete(perform: { viewModel.deleteReminders(offsets: $0) })
                                            
                        Button(action: viewModel.toggleReminderEditor) {
                            Label("Add reminder", systemImage: "plus")
                        }.sheet(isPresented: $viewModel.showReminderEditor) {
                            ReminderEditor(reminder: nil, onComplete: viewModel.addReminder)
                        }
                    }
                }
            }
        }
        .navigationTitle("Details")
        .navigationBarBackButtonHidden(false)
        .navigationBarItems(
            trailing:
            Button(action: {
                viewModel.save()
                self.presentationMode.wrappedValue.dismiss()
                                            
            }) {
                Text("Done")
            }
        )
        .onAppear {
            UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(tintColor)
            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        }
    }
}

struct TodoDetail_Previews: PreviewProvider {
    static var previews: some View {
        TodoDetail(entityId: "FnrWh38iEZ32MNTm3904")
    }
}

private var reminderDateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}
