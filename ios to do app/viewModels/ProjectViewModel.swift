//
//  ProjectViewModel.swift
//  ios to do app
//
//  Created by dasoya on 18.01.23.
//

import SwiftUI
import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

///ViewModel for all Projects List on HomeView
class ProjectViewModel : ObservableObject {

    
    private var db = Firestore.firestore()
    private var auth = Auth.auth()
    private var id: String?
    
    ///Publisched variables for binding with Home view
    @Published var filter: FilterType = .all
    @Published var projects: [(String, Project?)] = []
    @Published var newProject: Project = .init()
    
    @Published var error: Error?
    @Published var showAlert = false
    @Published var showReminderEditor = false
    
    @Published var selection: String?
    
    
    private var cancelables: [AnyCancellable] = []
    
    /// Initialize ProjectViewModel  by loading all projects associated with the current user.
    init() {
       
        self.loadList()

    }
    
    ///Retrieve projects associated with a user ID from the projects collection in the Firebase database
    func loadList(){
        
        guard let currentUserId = auth.currentUser?.uid else{
            error = AuthError()
            return
        }
        
        let collectionRef = Firestore.firestore().collection("projects").whereField("userId", in: [currentUserId])
       
        
        ///Funtion addSnapshotListener to the collection reference to listen for changes in the data
        collectionRef.addSnapshotListener { querySnapshot, error in
            if error != nil{
                self.showAlert = true
                self.error = error
                return
            }
            
            do{
                let docs = try querySnapshot?.documents.map({ docSnapshot -> (String, Project) in
                        let project = try docSnapshot.data(as: Project.self)
                        return (docSnapshot.documentID, project)
                });
                self.projects = docs!
            }catch {
                self.error = error
                self.showAlert = true
            }

            ///The projects are sorted based on the time they were created or modified.
            self.projects = self.projects.sorted(by: { $0.1?.timestamp ?? Date() < $1.1?.timestamp ?? Date() })
            
        }
    }
    
    ///Create a project based on user inputs, including name, color, and language.
    func addProject(projectInfo : ProjectInfo) {
            
      
        newProject.userId = auth.currentUser?.uid;
        newProject.projectName = projectInfo.projectName
        newProject.colorHexString = projectInfo.projectColor.toHex()
        newProject.selectedLanguage = projectInfo.selectedLanguage
        newProject.timestamp = Date()
        
            guard let documentId = id else {
                /// create a new project document from the firebase
                let newDocRef = db.collection("projects").document()
                id = newDocRef.documentID
                
                do {
                    try newDocRef.setData(from: newProject)
                    id = nil
                } catch {
                    self.error = error
                    self.showAlert = true
                }
                
                return
            }
            
        /// If the document id is not nil, save the project under that ID.
            do {
                
                try db.collection("projects").document(documentId).setData(from: newProject)
            
                
            } catch {
                self.error = error
                self.showAlert = true
            }
        
    }
    
    ///Modify a project selected by the user.
    func editProject(projectId: String, projectInfo : ProjectInfo) {

        let _project = Project(projectName: projectInfo.projectName, projectColor: projectInfo.projectColor, language: projectInfo.selectedLanguage)
        
        _project.userId = auth.currentUser?.uid;
        _project.timestamp = Date()
        
            do {
                
                try db.collection("projects").document(projectId).setData(from: _project)
            
            } catch {
                self.error = error
                self.showAlert = true
            }
        
    }
    
    ///Delete a project selected by the user.
    func deleteProject(projectId : String) {
        
        db.collection("projects").document(projectId).delete() { err in
                self.error = err
                self.showAlert = true
        }
  
    }

    
    
}


