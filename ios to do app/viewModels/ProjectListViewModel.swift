//
//  ProjectListViewModel.swift
//  ios to do app
//
//  Created by Cristi Conecini on 24.01.23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

///View Model for PojectListRow,  SearchableView in the Home View
class ProjectListViewModel: GenericTodoViewModel {
    
    let projectId: String
    private var cancelables: [AnyCancellable] = []
    private var querySubscription: ListenerRegistration?
    private var projectSubscription: ListenerRegistration?
    
    ///Publisched variables for binding with Home view and TodoListView
    @Published var filter: FilterType = .all
    @Published var progress: Double = 0.0
    @Published var project: Project?
    
    private var db = Firestore.firestore()
    
    ///Initialize ProjectListViewModel by loading a
    init(projectId: String){
        self.projectId = projectId
        super.init()
        
        setupBindings()
        loadProject()
        loadList(filter: filter)
    }
    
   ///Set up bindings for the project, the filter and the progress in the View Model
    func setupBindings(){
        $filter.receive(on: DispatchQueue.main).sink { filter in
            self.loadList(filter: filter)
        }.store(in: &cancelables)
        
        $todoList.receive(on: DispatchQueue.main).sink{
            list in
            let totalTodos = self.todoList.count
            guard totalTodos != 0 else {
                self.progress =  0
                return
            }
            let completedTodos = self.todoList.filter { $0.1.isCompleted }.count
            self.progress = Double(completedTodos) / Double(totalTodos)
        }.store(in: &cancelables)
    }
    
    ///Retrieve a project document based on project ID frome projects collection
    func loadProject(){
        projectSubscription = db.document("projects/\(projectId)").addSnapshotListener({ docSnapshot, error in
            if error != nil {
                self.showAlert = true
                self.error = error
                print("[ProjectListViewModel][loadProject] Error getting project \(error!.localizedDescription)")
                return
            }
            if((docSnapshot?.exists) != nil){
                do {
                    self.project = try docSnapshot?.data(as: Project.self)
                }catch{
                    self.error = error
                    self.showAlert = true
                    print("[ProjectListViewModel][loadProject] Error decoding project \(error.localizedDescription)")
                }
            }else{
                self.error = ProjectNotFoundError()
                self.showAlert = true
                print("[ProjectListViewModel][loadProject] Project does not exist")
            }
            
            
        })
    }
    

    /// Save a To-do item to the "todos" collection
    func saveTodo(entityId : String, Todo : Todo){
        do {
            try db.collection("todos").document(entityId).setData(from: Todo)
        } catch {
            self.error = error
            self.showAlert = true
        }
        
    }
    
    ///Retrieve the to-do list associated with a specific project ID from the "todos" collection in the database
    func loadList(filter: FilterType){
       
        querySubscription?.remove()
        
        let collectionRef = db.collection("todos").whereField("projectId", isEqualTo: projectId)
        
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
                print("[ProjectListViewModel][loadList] Error getting todo list \(error!.localizedDescription)")
                return
            }
            
            do {
                let docs = try querySnapshot?.documents.map { docSnapshot in
                    (docSnapshot.documentID, try docSnapshot.data(as: Todo.self))
                }
                self.todoList = docs!
                
            } catch {
                print("[ProjectListViewModel][loadList] Error decoding todo list \(error.localizedDescription)")
                self.error = error
                self.showAlert = true
            }
        }
        
    }
    
    deinit{
        querySubscription?.remove()
        projectSubscription?.remove()
    }
}
