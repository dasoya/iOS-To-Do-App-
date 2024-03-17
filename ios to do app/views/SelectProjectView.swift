//
//  SelectProjectView.swift
//  ios to do app
//
//  Created by Cristi Conecini on 30.01.23.
//

import SwiftUI

///List of projects of the current user allowing selection
struct SelectProjectView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var viewModel = ProjectViewModel()
    
    ///Handler for selection of new Project
    var onSelect: (_ projectId: String?, _ project: Project?) -> Void
    
    var body: some View {
        List(selection: $viewModel.selection){
            ForEach($viewModel.projects, id: \.0) { $item in
                HStack{
                    Circle().frame(width: 12, height: 12)
                        .overlay(
                            Circle().foregroundColor(Color(hex: item.1?.colorHexString ?? "#FFFFFF"))
                                .frame(width: 10, height: 10)
                        )
                    Text(item.1?.projectName ?? "Untitled")
                    Text(item.1?.selectedLanguage.name ?? "English")
                        .foregroundColor(.gray)
                }
            }
        }.environment(\.editMode, .constant(EditMode.active))
        HStack{
            Button("Remove project"){
                dismiss()
                onSelect("", nil)
            }
            Button("Move"){
                guard let projectId = viewModel.selection else {
                    return
                }
                
                guard let project = viewModel.projects.first(where: { (id, _) in
                    viewModel.selection == id
                })?.1 else {
                    return
                }
                dismiss()
                onSelect(projectId, project)
            }.disabled(viewModel.selection == nil).padding()
        }
        
    }
}

struct SelectProjectView_Previews: PreviewProvider {
    static var previews: some View {
        SelectProjectView(onSelect: {projectId, project in })
    }
}
