//
//  TodoEditorViewModel.swift
//  ios to do app
//
//  Created by Cristi Conecini on 17.01.23.
//

import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import SwiftUI

/// This class is for creating and modifying a project 
class TodoEditorViewModel: ObservableObject {
    @Environment(\.presentationMode) var presentation
    
    private var cancellables: [AnyCancellable] = []
    
    private var db = Firestore.firestore()
    private var auth = Auth.auth()
    private var id: String?
    
    ///Published variables to store a to-do information
    @Published var todo: Todo = .init()
    @Published var project: Project?
    @Published var reminderList: [Reminder] = []
    @Published var flashcards: [Flashcard] = []
    
    @Published var error: Error?
    @Published var showAlert = false
    @Published var showReminderEditor = false
    @Published var showFlashcardEditor = false
    @Published var showProjectSelector = false
    
    
    ///Initialize TodoEditorViewModel with 'todos' document id
    init(id: String?) {
        self.id = id
        getTodo()
        setupRestrictions()
    }
    
    ///Initialize TodoEditorViewModel with 'projects' document id
    init(projectId: String = "") {
        todo.projectId = projectId
        getProject(projectId: projectId)
    }
    
    private func setupRestrictions() {
        todo.$startDate.sink {
            _ in
            self.todo.dueDate = Date()
        }.store(in: &cancellables)
    }
        
    private func getTodo() {
        guard let id = id else {
            return
        }
        
        let docRef = db.collection("todos").document(id)
        
        docRef.getDocument(as: Todo.self) { result in
            
            switch result {
                case .success(let todo):
                    self.todo = todo
                    self.reminderList = todo.reminders
                    self.flashcards = todo.flashcards
                self.getProject(projectId: todo.projectId ?? "")
                    
                case .failure(let error):
                    self.error = error
                    self.showAlert = true
            }
        }
    }
    
    func getProject(projectId id: String){
        guard id.count > 0 else {
            return
        }
        
        let docRef = db.collection("projects").document(id)
        docRef.getDocument(as: Project.self) { result in
            switch result {
            case .success(let project):
                self.project = project
            case .failure(let error):
                self.error = error;
                self.showAlert = true;
            }
        }
    }
    
    func muteDefaultReminder() {
        todo.reminderBeforeDueDate.negate()
        objectWillChange.send()
    }
    
    func toggleReminderEditor() {
        showReminderEditor.toggle()
    }

    func toggleFlashcardEditor() {
        showFlashcardEditor.toggle()
    }
    
    func addReminder(reminder: Reminder) {
        reminderList.append(reminder)
    }

    func addFlashcard(flashcard: Flashcard) {
        flashcards.append(flashcard)
    }

    func deleteFlashcard(offsets: IndexSet) {
        flashcards.remove(atOffsets: offsets)
    }
    
    func deleteReminders(offsets: IndexSet) {
        reminderList.remove(atOffsets: offsets)
    }
    
    ///Save todo information to firebase Database
    func save() {
        todo.reminders = reminderList
        todo.flashcards = flashcards
        todo.userId = auth.currentUser?.uid
        guard let documentId = id else {
            let newDocRef = db.collection("todos").document()
            id = newDocRef.documentID
            
            do {
                try newDocRef.setData(from: todo)
            } catch {
                self.error = error
                showAlert = true
            }
            
            return
        }
        
        guard todo.projectId != nil else {
            print("project id nill")
            
            return
        }
        
        do {
            try db.collection("todos").document(documentId).setData(from: todo)
        } catch {
            self.error = error
            showAlert = true
        }
    }
    
    deinit {}
}
