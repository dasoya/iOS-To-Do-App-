//
//  SaveTodoViewModel.swift
//  ios to do app
//
//  Created by Max on 27.01.23.
//

import Foundation


import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation


/// This view model is the basis for the TodayViewModel, UpcomingViewMode, ProjectListViewModel and TodoListView model. It has a filtered and unfiltered list of todos and provides a saving functionality as well as a method that clones recurring todos if necessary
class GenericTodoViewModel: ObservableObject {
    @Published var showAlert = false
    @Published var error: Error?
    @Published var todoList: [(String, Todo)] = []
    @Published var unfilteredTodoList: [(String, Todo)] = []
    
    @Published var selection = Set<String>()
    
    @Published var showMoveToProject = false
    @Published var showChangeDueDate = false
    @Published var showChangePriority = false
    
    let semaphore = DispatchSemaphore(value: 1)
    
    private var querySubscription: ListenerRegistration?

    init() {
        self.loadUnfilteredList()
    }
    
    /// should reload all todo lists and should therefore also be overidden by subclasses
    func refresh() {
        self.loadUnfilteredList()
    }
    
    /// Moves the selected items to a project specified by the projectId parameter.
    /// - Parameter projectId: An optional String representing the identifier of the project to which the selected items should be moved. If nil, the items are moved to the default project and this means it isn't part of any project.
    func selectionMoveToProject(projectId: String?){
        let db = Firestore.firestore()
        
        guard !selection.isEmpty else {
            return
        }
        
        let selectedEntries = todoList.filter { (id, todo) in
            selection.contains(id)
        }
        
        
        db.runTransaction { transaction, error in
            let refrences = selectedEntries.map { (id, _) in
                
                db.document("/todos/\(id)")
            }
            
            for d in refrences{
                transaction.updateData(["projectId" : projectId ?? ""], forDocument: d)
            }
            return nil
        } completion: {_,_ in
            print("successfully saved changes")
        }

        
    }
    
    /// Changes the due date of the selected items to the date specified by the newDueDate parameter.
    /// - Parameter newDueDate: A Date object representing the new due date for the selected items.
    func selectionChangeDueDate(newDueDate: Date){
        let db = Firestore.firestore()
        
        
        
        guard !selection.isEmpty else {
            return
        }
        
        let selectedEntries = todoList.filter { (id, todo) in
            selection.contains(id)
        }
        
        
        db.runTransaction { transaction, error in
            let refrences = selectedEntries.map { (id, _) in
                
                db.document("/todos/\(id)")
            }
            
            for d in refrences{
                transaction.updateData(["dueDate" : newDueDate.ISO8601Format()], forDocument: d)
            }
            
            return nil
        } completion: {_,err in
            guard err != nil else {
                print("saved chages!");
                return
            }
            
            self.error = err;
            self.showAlert = true
        }

        
    }
    
    /// Changes the priority of the selected items to the priority specified by the newPriority parameter.
    /// - Parameter newPriority: A Priority enum representing the new priority for the selected items.
    func selectionChangePriority(newPriority: Priority){
        let db = Firestore.firestore()
        
        
        
        guard !selection.isEmpty else {
            return
        }
        
        let selectedEntries = todoList.filter { (id, todo) in
            selection.contains(id)
        }
        
        
        db.runTransaction { transaction, error in
            let refrences = selectedEntries.map { (id, _) in
                
                db.document("/todos/\(id)")
            }
            
            for d in refrences{
                transaction.updateData(["priority" : newPriority.rawValue], forDocument: d)
            }
            
            return nil
        } completion: {_,err in
            guard err != nil else {
                print("saved chages!");
                return
            }
            
            self.error = err;
            self.showAlert = true
        }

    }
    
    /// Deletes the items specified by the indexSet parameter from the selection.
    /// - Parameter indexSet: An optional IndexSet representing the indices of the items to be deleted from the selection. If nil, all items are deleted.
    func deleteSelection(indexSet: IndexSet?){
        let db = Firestore.firestore()
        
        guard let indexes = indexSet else {
            return
        }
    
            let selectedRefrences = indexes.map { index in
                let id = todoList[index].0
                return db.document("/todos/\(id)")
            }
       
        
        db.runTransaction { transaction, err in
            
            for d in selectedRefrences {
                transaction.deleteDocument(d);
            }
            
            return nil
        } completion: { _, err in
            guard err != nil else {
                print("saved chages!");
                return
            }
            
            self.error = err;
            self.showAlert = true
        }

    }
    
    
    /// loads all todos for the current user and saves them as self.unfilteredTodoList.  This list is mainly needed because of the cloneRecurringTodoIfNecessary-function.
    func loadUnfilteredList(){
        querySubscription?.remove()
        
        guard let currentUserId = Auth.auth().currentUser?.uid else{
            error = AuthError()
            return
        }
        
        let collectionRef = Firestore.firestore().collection("todos").whereField("userId", isEqualTo: currentUserId)
        
        let queryRef: Query = collectionRef
        
        self.querySubscription = queryRef.addSnapshotListener { querySnapshot, error in
            if error != nil {
                self.showAlert = true
                self.error = error
                print("[GenericTodoViewModel][loadList] Error getting todo list \(error!.localizedDescription)")
                return
            }
            
            do {
                let docs = try querySnapshot?.documents.map { docSnapshot in
                    (docSnapshot.documentID, try docSnapshot.data(as: Todo.self))
                }
                self.unfilteredTodoList = docs!
                
            } catch {
                print("[GenericTodoViewModel][loadList] Error decoding todo list \(error.localizedDescription)")
                self.error = error
                self.showAlert = true
            }
        }
        
    }
    
    
    /// Recurring todos should be duplicated when marking them as done. This function takes care of this and also makes sure that a todo can't be duplicated twice if the checkmark is toggled mutiple times
    /// - Parameters:
    ///   - entityId: id of the todo that might be clonsed
    ///   - todo: the todo object that might be cloned
    func cloneRecurringTodoIfNecessary(entityId : String, todo : Todo) {
        // semaphore.wait()
        // only clone when todo is marked done and is recurring
        if !todo.isCompleted || todo.recurring == .none {
            return
        }
        
        // only clone if it wasn't cloned before
        if unfilteredTodoList.contains(where: {(_, todo) in
            todo.createdByRecurringTodoId == entityId
        }) {
           return
        }
        
        // copy the todo
        
        let todoData = try! JSONEncoder().encode(todo)
        let copiedTodo = try! JSONDecoder().decode(Todo.self, from: todoData)
        
        // set the new todo not completed
        
        copiedTodo.isCompleted = false
        
        // set the next due and start date such that the due date is not reached and in the recurring schedule
        
        if (copiedTodo.recurring != .monthly) {
            for i in 1...10000 {
              
                if let recurringInterval = TimeInterval(exactly: 60 * 60 * 24 * (copiedTodo.recurring == .daily ? 1 : 7) * i) {
                    let newDueDate = copiedTodo.dueDate.addingTimeInterval(recurringInterval)
                    let newStartDate = copiedTodo.startDate.addingTimeInterval(recurringInterval)
                    if newDueDate < Date() {
                        continue
                    }
                    copiedTodo.dueDate = newDueDate
                    copiedTodo.startDate = newStartDate
                    break
                }
            }
        } else {
            let calendar = Calendar.current
            for i in 1...10000 {
            
                if let newDueDate = calendar.date(byAdding: .month, value: i, to: copiedTodo.dueDate) {
                    if newDueDate < Date() {
                        continue
                    }
                    if let newStartDate = calendar.date(byAdding: .month, value: i, to: copiedTodo.startDate) {
                        copiedTodo.dueDate = newDueDate
                        copiedTodo.startDate = newStartDate
                    }
                    break
                }
            }
        }
        
        // set createdByRecurringTodoId
        
        copiedTodo.createdByRecurringTodoId = entityId
        
        let db = Firestore.firestore()
        let newDocRef = db.collection("todos").document()
        
        do {
            try newDocRef.setData(from: copiedTodo)
        } catch {
            self.error = error
            self.showAlert = true
        }

        // done
        self.refresh()
        self.objectWillChange.send()
        //        semaphore.signal()
        
    }
    
    
    /// This function saves a specific todo to the firestore database. It's mainly used to save the current state of "isCompleted" when the checkmark is pressed.
    /// - Parameters:
    ///   - entityId: the id of the todo that should be saved
    ///   - todo: the todo object that should be saved
    func saveTodo(entityId : String, todo : Todo) {
        let db = Firestore.firestore()
        do {
            try db.collection("todos").document(entityId).setData(from: todo)
        } catch {
            self.error = error
            self.showAlert = true
        }
           
    }
    
    deinit{
        querySubscription?.remove()
    }
}
