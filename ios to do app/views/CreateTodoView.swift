//
//  CreateTodo.swift
//  ios to do app
//
//  Created by Cristi Conecini on 14.01.23.
//

import Combine
import SwiftUI

/// View which allows the creation of todos with details
struct CreateTodoView: View {
    @Environment(\.presentationMode) var presentation
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.tintColor) var tintColor
    
    @ObservedObject private var viewModel: TodoEditorViewModel
    @ObservedObject private var projectViewModel = ProjectViewModel()
    @State private var showBeforeDueDatePicker = false
    
    private var languageList = Language.getAllLanguages()
    
    /// Initialize CreateTodoView.
    ///
    /// Associated project will be chosen later
    init() {
        viewModel = TodoEditorViewModel()
    }
    
    /// Initialize CreateTodoView and associte the new to do to the specified project
    /// - Parameters:
    ///   - projectId: id of the project to associate with
    init(projectId: String) {
        viewModel = TodoEditorViewModel(projectId: projectId)
    }
    
    func setAppIcon(tintColor: String, themePrefix: String) {
        Task {
            await RemindersWidgetAppIconUtil.setAppIcon(tintColor: tintColor, themePrefix: themePrefix)
        }
    }
    
    private func saveTodo() {
        viewModel.save()
        close()
        setAppIcon(tintColor: "#\(tintColor.toHex()?.lowercased() ?? "" )", themePrefix: colorScheme == .dark ? "Dark" : "Light")
        
        
    }
    
    private func close() {
        presentation.wrappedValue.dismiss()
    }
    
    var body: some View {
        VStack {
            Form {
                /// Task Details
                Section(header: Text("Task Details")) {
                    Group {
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
                }
                    
                /// Aditional Details
                Section(header: Text("Additional Details")) {
                    if dynamicTypeSize > DynamicTypeSize.medium {
                        VStack(alignment: .leading) {
                            Text("Start Date")
                            DatePicker(selection: $viewModel.todo.startDate, in: Date()..., displayedComponents: [.date, .hourAndMinute]) {}
                        }
                        VStack(alignment: .leading) {
                            Text("Due Date")
                            DatePicker(selection: $viewModel.todo.dueDate, in: viewModel.todo.startDate..., displayedComponents: [.date, .hourAndMinute]) {}
                        }
                    } else {
                        HStack {
                            Text("Start Date")
                            DatePicker(selection: $viewModel.todo.startDate, in: Date()..., displayedComponents: [.date, .hourAndMinute]) {}
                        }
                        HStack {
                            Text("Due Date")
                            DatePicker(selection: $viewModel.todo.dueDate, in: viewModel.todo.startDate..., displayedComponents: [.date, .hourAndMinute]) {}
                        }
                    }
                    Group {
                        Picker(selection: $viewModel.todo.priority, label: Text("Priority")) {
                            ForEach(Priority.allCases, id: \.self) { v in
                                Text(v.localizedName).tag(v)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        Picker(selection: $viewModel.todo.recurring, label: Text("Recurring")) {
                            ForEach(Recurring.allCases, id: \.self) { v in
                                Text(v.localizedName).tag(v)
                            }
                        }
                    }
                }
                    
                /// Reminders
                Section(header: Text("Reminders")) {
                    List {
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
                            // TimePicker(selectedTime: self.$selectedTime)TimePicker(selectedTime: $viewModel.todo.reminderBeforeDueDate)
                                
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
        .navigationTitle("New Todo")
        .navigationBarTitleDisplayMode(.large)
        .toolbar(content: {
            ToolbarItem(placement: .confirmationAction) {
                Button("Add", action: saveTodo)
                    .disabled(viewModel.todo.task.isEmpty)
                    .padding()
                    .cornerRadius(15)
                    .alert("Error saving ToDo", isPresented: $viewModel.showAlert, actions: {
                        Button("Ok", action: { self.viewModel.showAlert = false })
                    }, message: { Text(self.viewModel.error?.localizedDescription ?? "Unknown error") })
            }
        })
        .onAppear {
            UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(tintColor)
            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        }
    }
}
    
struct RemindMeBeforeDueDatePicker: View {
    @Binding var reminderBeforeDueDate: Int
    @Binding var isPresented: Bool
        
    var body: some View {
        VStack {
            Text("Remind me...")
                .multilineTextAlignment(TextAlignment.center)
                
                .padding()
                
            Picker("Select time", selection: $reminderBeforeDueDate) {
                Text("5 minutes").tag(5)
                Text("10 minutes").tag(10)
                Text("15 minutes").tag(15)
                Text("30 minutes").tag(30)
                Text("1 hour").tag(60)
                Text("2 hours").tag(120)
                Text("1 day").tag(1440)
            }.pickerStyle(.wheel)
            Text("...before due date.").multilineTextAlignment(TextAlignment.center)
                .padding()
                
            Button("Save") {
                // Save the selected time and close the sheet
                self.isPresented = false
            }
        }
    }
}
    
struct TodoEditor_Previews: PreviewProvider {
    static var previews: some View {
        CreateTodoView()
    }
}
    
private var reminderDateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}

/// View which allows the creation of todos quickly with task name
struct CreateQuickTodoView: View {
    @Environment(\.tintColor) var tintColor
        
    @Binding private var showModal: Bool
    @ObservedObject private var viewModel: TodoEditorViewModel
        
    init(show: Binding<Bool>) {
        viewModel = TodoEditorViewModel()
        _showModal = show
    }
        
    init(projectId: String, show: Binding<Bool>) {
        viewModel = TodoEditorViewModel(projectId: projectId)
        _showModal = show
    }
        
    private func saveTodo() {
        viewModel.todo.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        viewModel.save()
    }
        
    var body: some View {
        VStack {
            HStack {
                TextField("Task Name", text: $viewModel.todo.task)
                    
                Spacer()
                    
                Text("Cancel")
                    .onTapGesture {
                        showModal = false
                    }
                    .foregroundColor(tintColor)
            }
            HStack {
                Text("Create Task")
                    .onTapGesture {
                        saveTodo()
                        showModal = false
                    }.foregroundColor(viewModel.todo.task.isEmpty ? .gray : tintColor)
                    .disabled(viewModel.todo.task.isEmpty)
                    .alert("Error add todo", isPresented: $viewModel.showAlert, actions: {
                        Button("Ok", action: { self.viewModel.showAlert = false })
                    }, message: { Text(self.viewModel.error?.localizedDescription ?? "Unknown error") })
            }
        }
    }
}
