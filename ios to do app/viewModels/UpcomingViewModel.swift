//
//  UpcomingViewModel.swift
//  ios to do app
//
//  Created by Cristi Conecini on 25.01.23.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift
import Combine


/// View model for the UpcomingView
class UpcomingViewModel: GenericTodoViewModel {
    
    private var cancelables: [AnyCancellable] = []
    private var querySubscription: ListenerRegistration?
    
    
    @Published var filter: FilterType = .all
    
    var lastActiveFilter: FilterType = .all
    var lastStartDate: Date?
    var lastEndDate: Date?
    
    
    @Published var progress: Double = 0.0
    @Published var selectedWeekday: Int = 0
    
    override init(){
        super.init()
        setupBindings()
        selectedWeekday = Calendar.current.component(.weekday, from: Date()) - 1
        do{
            let (s, e) = try determineDateRange(weekday: selectedWeekday+1)
            loadList(filter: filter, startDate: s, endDate: e)
        }catch{
            self.error = error
            self.showAlert = true
        }
    }
    
    override func refresh() {
        if let lsd = lastStartDate, let led = lastEndDate {
            loadList(filter: lastActiveFilter, startDate: lsd, endDate: led)
        }
        
        super.refresh()
    }
    
    /// Determines the date range for a specific weekday specified by the weekday parameter and returns the start and end dates for that range.
    /// - Parameter weekday: An Int representing the weekday (e.g. Monday = 0, Tuesday = 1, etc.).
    /// - Returns:  A tuple of two Date objects representing the start and end dates of the date range for the specified weekday.
    private func determineDateRange(weekday: Int) throws ->  (Date, Date){
        let currentDate = Date()
        
        let calender = Calendar.current
        
        let currentWeekday = calender.component(.weekday, from: currentDate)
        
        var componentsToSubtract = DateComponents()
        componentsToSubtract.weekday = weekday - currentWeekday
        
        guard let selectedDate = calender.date(byAdding: componentsToSubtract, to: currentDate) else {
            throw DateError()
        }
        
        
        guard let startHour = calender.date(bySettingHour: 0, minute: 0, second: 0, of: selectedDate ),
              let endHour = calender.date(bySettingHour: 23, minute: 59, second: 59, of: selectedDate ) else{
            throw DateError()
        }
        return (startHour,endHour)
    }
    
    /// Makes sure the view is properly when the todolist or the selectedWeekday changes
    func setupBindings(){
        $todoList.receive(on: DispatchQueue.main).sink{
            list in
            let totalTodos = self.todoList.count
            guard totalTodos != 0 else {
                self.progress =  1
                return
            }
            let completedTodos = self.todoList.filter { $0.1.isCompleted }.count
            self.progress = Double(completedTodos) / Double(totalTodos)
        }.store(in: &cancelables)
        
        
        $selectedWeekday.receive(on: DispatchQueue.main).sink { weekday in
            do{
                let (s, e) = try self.determineDateRange(weekday: weekday + 1)
                self.lastStartDate = s
                self.lastEndDate = e
                self.loadList(filter: self.filter, startDate: s, endDate: e)
            }catch {
                self.error = error
                self.showAlert = true
            }
        }.store(in: &cancelables)
    }

    
    
    /// Loads a list of to-dos based on the specified filter and only includes those with a due date between the startDate and endDate parameters.
    /// - Parameters:
    ///   - filter: A FilterType (e.g. show all todos, show only completed ...)
    ///   - startDate: The start date of the range
    ///   - endDate: The end date of the range
    func loadList(filter: FilterType, startDate: Date, endDate: Date){
        lastActiveFilter = filter
        querySubscription?.remove()
        
        guard let currentUserId = Auth.auth().currentUser?.uid else{
            error = AuthError()
            return
        }
        
        let collectionRef = Firestore.firestore().collection("todos")
            .whereField("userId", isEqualTo: currentUserId)
            .whereField("dueDate", isGreaterThanOrEqualTo: startDate.ISO8601Format())
            .whereField("dueDate", isLessThanOrEqualTo: endDate.ISO8601Format())
        
        var queryRef: Query
        
        switch filter {
            case .completed: queryRef = collectionRef.whereField("isCompleted", isEqualTo: true)
            case .incomplete: queryRef = collectionRef.whereField("isCompleted", isEqualTo: false)
            default: queryRef = collectionRef
        }
    
        
        self.querySubscription = queryRef.addSnapshotListener { querySnapshot, error in
            if error != nil {
                self.showAlert = true
                self.error = error
                print("[UpcomingViewModel][loadList] Error getting todo list \(error!.localizedDescription)")
                return
            }
            
            do {
                let docs = try querySnapshot?.documents.map { docSnapshot in
                    (docSnapshot.documentID, try docSnapshot.data(as: Todo.self))
                }
                self.todoList = docs!
                
            } catch {
                print("[UpcomingViewModel][loadList] Error decoding todo list \(error.localizedDescription)")
                self.error = error
                self.showAlert = true
            }
        }
        
    }
    
    deinit{
        querySubscription?.remove()
    }
    
    
}
