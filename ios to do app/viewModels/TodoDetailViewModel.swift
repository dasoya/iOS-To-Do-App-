//
//  TodoDetailViewModel.swift
//  ios to do app
//
//  Created by Cristi Conecini on 17.01.23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

/// ViewModel to display the details of a Todo
class TodoDetailViewModel: ObservableObject{
    
    @Published var todo: Todo = .init()
    @Published var id: String
    @Published var error: Error?
    
    
    let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    /// Creates an instance with the given todo id
    ///
    /// Parameters:
    ///     - entityId: The todo id
    init(entityId: String){
        self.id = entityId
        getData()
    }
    
    /// Fetch the details of todo
    func getData(){
            let docRef = db.collection("todos").document(id)
            
        listenerRegistration = docRef.addSnapshotListener { snapshot, error in
            if error != nil{
                self.error = error
            }
            
            do{
                try self.todo = snapshot!.data(as: Todo.self)
            }catch{
                print("Error decoding todo \(error.localizedDescription)")
                self.error = error
            }
        }
    }
    
    deinit{
        listenerRegistration?.remove()
    }
}
