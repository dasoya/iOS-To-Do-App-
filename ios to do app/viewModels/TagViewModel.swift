//
//  TagViewModel.swift
//  ios to do app
//
//  Created by Amit Kumar Shaw on 25.01.23.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

/// ViewModel for Tags
class TagViewModel : ObservableObject {

    
    private var db = Firestore.firestore()
    private var auth = Auth.auth()
    private var id: String?
    @Published var filter: FilterType = .all

    @Published var tags: [(String, Tag?)] = []
    @Published var selectableTags: [(String, Tag, Bool)] = []
    @Published var newTag: Tag = .init()
    
    @Published var error: Error?
    @Published var showAlert = false
    
    private var cancelables: [AnyCancellable] = []
    
    init(id: String?) {
        self.id = id
        getTag()
    }
    
    init() {
       
        self.loadList()

    }
    
    /// load all the tags of the user from the database
    func loadList(){
        
        guard let currentUserId = auth.currentUser?.uid else{
            error = AuthError()
            return
        }
        
        let collectionRef = Firestore.firestore().collection("tags").whereField("userId", in: [currentUserId])
       
        
        collectionRef.addSnapshotListener { querySnapshot, error in
            if error != nil{
                self.showAlert = true
                self.error = error
                return
            }
            
            do{
                let docs = try querySnapshot?.documents.map({ docSnapshot -> (String, Tag) in
                        let tag = try docSnapshot.data(as: Tag.self)
                        return (docSnapshot.documentID, tag)
                });
                self.tags = docs!
                self.selectableTags = []
                self.tags.forEach { item in
                    self.selectableTags.append((item.0, item.1!, false))
                }
            }catch {
                self.error = error
                self.showAlert = true
            }

            self.tags = self.tags.sorted(by: { $0.1?.timestamp ?? Date() < $1.1?.timestamp ?? Date() })
            
        }
    }
    
    /// Fetch a tag with the given id
    private func getTag() {
        if id != nil {
            let docRef = db.collection("tags").document(id!)
            
            docRef.getDocument(as: Tag.self) { result in
                
                switch result {
                    case .success(let tag):
                        self.newTag = tag
                    
                    case .failure(let error):
                        print("Error getting tag \(error)")
                }
            }
        }
    }
    
    /// Adds a new tag to the database
    /// - Parameters:
    ///   - tag: Tag name
    ///   - todo: Optional todo to add it to the tag
    func addTag(tag: String, todo : String?) {
            
      
        newTag.userId = auth.currentUser?.uid;
        newTag.tag = tag
        newTag.todos.append(todo!)
        newTag.timestamp = Date()
        
            guard let documentId = id else {
                // add new tag
                let newDocRef = db.collection("tags").document()
                id = newDocRef.documentID
                
                do {
                    try newDocRef.setData(from: newTag)
                    id = nil
                } catch {
                    self.error = error
                    self.showAlert = true
                }
                
                return
            }
            
            do {
                
                try db.collection("tags").document(documentId).setData(from: newTag)
            
            } catch {
                self.error = error
                self.showAlert = true
            }
        
    }
    
    /// Deletes a tag
    /// - Parameters:
    ///   - id: Id of the tag to delete
    func deleteTag(id: String) {
        
        let tagId = id
        
        // Delete the tag
        db.collection("tags").document(tagId).delete() { err in
                self.error = err
                self.showAlert = true
        }
            
        self.loadList()
    }
    
    /// Adds a todo to the given tag
    /// - Parameters:
    ///   - id: Tag id
    ///   - todo: Todo id to add it to the tag
    func addTodo(id: String, todo: String) {
       
        let docRef = db.collection("tags").document(id)
        docRef.getDocument(as: Tag.self) { result in
            
            switch result {
                case .success(let tag):
                    
                tag.todos.append(todo)
                do {
                    try docRef.setData(from: tag)
                } catch {
                    self.error = error
                    self.showAlert = true
                }
                
                case .failure(let error):
                    print("Error getting tag \(error)")
            }
        }
    }
    
    /// Remove a todo from the given tag
    /// - Parameters:
    ///   - id: Tag id
    ///   - todo: Todo id to add it to the tag
    func removeTodo(id: String, todo: String) {
       
        let docRef = db.collection("tags").document(id)
        docRef.getDocument(as: Tag.self) { result in
            
            switch result {
                case .success(let tag):
                    
                tag.todos = tag.todos.filter {$0 != todo}
                do {
                    try docRef.setData(from: tag)
                } catch {
                    self.error = error
                    self.showAlert = true
                }
                
                case .failure(let error):
                    print("Error getting tag \(error)")
            }
        }
    }
    
    /// Calculate the number of tags for a todo
    ///
    /// - Parameters:
    ///   - todo: Todo id
    ///
    ///  Returns: Number of tags selected for the todo
    func tagCount(todo: String) -> Int {
        var count = 0
      
        tags.forEach { item in
            if item.1!.todos.contains(todo) {
                count += 1
            }
        }
        
        return count
    }
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
}
