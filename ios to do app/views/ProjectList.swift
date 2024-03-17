import SwiftUI
import Foundation

/// View for each row in the project list.
struct ProjectListRow: View {
    
    
    /// Binding for the project to display in the row.
    @Binding var project : Project?
    
    /// Binding for the flag to indicate if the list is sorted by language.
    @Binding var isSortedByLanguage : Bool
    
    /// String to store the project's identifier.
    @State var projectId :String
    
    /// State to store the flag to show the modal view.
    @State var showModal = false
    
    /// Observed object to store the view model for the projects.
    @ObservedObject var viewModel = ProjectViewModel()
    
    /// Initializer that takes in the project and the flag to indicate if the list is sorted by language.
    /// - Parameters:
    ///    - project: Tuple of projectId and and an optional binding object of Project class
    ///    - isSortedByLanguage:Boolean to order by language
    init(project: (String, Binding<Project?>),isSortedByLanguage: Binding<Bool>){
        
        self._project = project.1
        self.projectId = project.0
        self._isSortedByLanguage = isSortedByLanguage
    }
    
    /// Initializer that takes in only the project.
    /// - Parameters:
    ///    - project: Tuple of projectId and and an optional binding object of Project class
    init(project: (String, Binding<Project?>)){
        self._project = project.1
        self.projectId = project.0
        self._isSortedByLanguage = .constant(false)
    }
    
    var body: some View {
        HStack {
            Circle()
                .foregroundColor(Color(hex: project!.colorHexString ?? "#FFFFFF"))
                .frame(width: 12, height: 12)
            Text(project!.projectName ?? "Untitled")
            Text(project!.selectedLanguage.name)
                .foregroundColor(.gray)
        }
        .swipeActions(){
            /// Action to show the modal view with project information.
            Button (action: {
                showModal = true
                isSortedByLanguage = false
            }){
                Label("info", systemImage: "info.circle")
            }.tint(.indigo)
            
            /// Action to delete the project.
            Button (action: {
                viewModel.deleteProject(projectId : projectId)
                isSortedByLanguage = false
            }){
                Label("delete", systemImage: "minus.circle")
            }.tint(.red)
            
        }.sheet(isPresented: $showModal) {
        
            CreateProjectView(project: (self.projectId, self.$project), showModal: $showModal)
            
        }
        
    }
    
}

