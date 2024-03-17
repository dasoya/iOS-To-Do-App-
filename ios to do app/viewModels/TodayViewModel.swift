//
//  TodayViewModel.swift
//  ios to do app
//
//  Created by Cristi Conecini on 25.01.23.
//

import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

/// View model for the TodayView
class TodayViewModel: GenericTodoViewModel {
    private var cancelables: [AnyCancellable] = []
    private var querySubscription: ListenerRegistration?
    
    @Published var filter: FilterType = .all
    @Published var lastActiveFilter: FilterType = .all
    @Published var progress: Double = 0.0
    
    override init() {
        super.init()
        setupBindings()
        loadList(filter: filter)
        
    }
    
    override func refresh() {
        loadList(filter: lastActiveFilter)
        super.refresh()
    }
    
    /// Initializes Publisher bindings for seamlessly updating state
    private func setupBindings() {
        $todoList.receive(on: DispatchQueue.main).sink {
            _ in
            let totalTodos = self.todoList.count
            guard totalTodos != 0 else {
                self.progress = 1
                return
            }
            let completedTodos = self.todoList.filter { $0.1.isCompleted }.count
            self.progress = Double(completedTodos) / Double(totalTodos)
        }.store(in: &cancelables)
    }
    
    /// Determine start and end date for querrying todos that are due on the current day
    /// - Returns: Tuple containing startHour and endHour
    private func determineDateRange() throws -> (Date, Date) {
        let currentDate = Date()
        
        let calender = Calendar.current
        
        guard let startHour = calender.date(bySettingHour: 0, minute: 0, second: 0, of: currentDate),
              let endHour = calender.date(bySettingHour: 23, minute: 59, second: 59, of: currentDate)
        else {
            throw DateError()
        }
        return (startHour, endHour)
    }

    /// Loads the list of todos due today from firestore
    /// - Parameters:
    /// - filter: filtering condition in regard to the completion status
    func loadList(filter: FilterType) {
        lastActiveFilter = filter
        querySubscription?.remove()
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            error = AuthError()
            return
        }
        
        let collectionRef = Firestore.firestore().collection("todos").whereField("userId", isEqualTo: currentUserId)
        
        var queryRef: Query
    
        do {
            let (startHour, endHour) = try determineDateRange()
            queryRef = collectionRef.whereField("dueDate", isGreaterThanOrEqualTo: startHour.ISO8601Format())
                .whereField("dueDate", isLessThanOrEqualTo: endHour.ISO8601Format())
            
            switch filter {
                case .completed: queryRef = queryRef.whereField("isCompleted", isEqualTo: true)
                case .incomplete: queryRef = queryRef.whereField("isCompleted", isEqualTo: false)
                case .all: break
            }
        
            querySubscription = queryRef.addSnapshotListener { querySnapshot, error in
                if error != nil {
                    self.showAlert = true
                    self.error = error
                    print("[TodayViewModel][loadList] Error getting todo list \(error!.localizedDescription)")
                    return
                }
                
                do {
                    let docs = try querySnapshot?.documents.map { docSnapshot in
                        (docSnapshot.documentID, try docSnapshot.data(as: Todo.self))
                    }
                    self.todoList = docs!
                    
                } catch {
                    print("[TodayViewModel][loadList] Error decoding todo list \(error.localizedDescription)")
                    self.error = error
                    self.showAlert = true
                }
            }
            
        } catch {
            print("Error filtering todos")
            self.error = error
            showAlert = true
            return
        }
        
        
        
        
    }
    
    deinit {
        querySubscription?.remove()
    }
}
