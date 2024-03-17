//
//  CreateProjectView.swift
//  ios to do app
//
//  Created by dasoya on 24.01.23.
//

import SwiftUI

/// Represents the UI for creating a new project.
struct CreateProjectView: View {
        
    @Environment(\.tintColor) var tintColor
    
    @State var projectInfo : ProjectInfo = ProjectInfo()

    @Binding var selectedProject : Project?
    @Binding var showModal: Bool
    @ObservedObject var viewModel = ProjectViewModel()
    @State var editMode : Bool = true

    ///Initialize CreateProjectView for creating a new project.
    init(project: Binding<Project?>,showModal: Binding<Bool>){
        editMode = false
        self._showModal = showModal
        self._selectedProject = project
       
    }
    
    /// Initialize CreateProjectView for modifying a project.
    init(project: (String,Binding<Project?>), showModal: Binding<Bool>){
        
        projectInfo = ProjectInfo(project: (project.0,project.1.wrappedValue!))
        self._selectedProject = project.1
        self._showModal = showModal
    }
    
    
    private let colorPalette : [String] = ["#d6542c","#eda28a","#124c81","#4e6190","#99a8bb","#3c345c","#a3c024","#f6bd74","#a098c2","#3c3c34","#afa356","#71a511"]
    private let columns = [GridItem(.adaptive(minimum: 80))]
    
    
    
    fileprivate func selectProjectNameView() -> some View {
        return VStack{
            Text("Create Project")
                .bold()
                .font(.title)
                .foregroundColor(tintColor)
            
            
            TextField("Project Name", text: self.$projectInfo.projectName)
                .frame(height: 55)
                .textFieldStyle(PlainTextFieldStyle())
                .padding([.horizontal], 4)
                .background(Color(UIColor.systemGroupedBackground))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(UIColor.systemGroupedBackground))
                )
            
        }
    }
    
    fileprivate func selectLanguageView() -> some View {
        return Picker(selection: self.$projectInfo.selectedLanguage, label: Text("Language")) {
            LanguageList()
        }.onReceive([self.projectInfo.selectedLanguage].publisher.first()) { (value) in
            self.projectInfo.selectedLanguage = value
            
        }
    }
    
    fileprivate func selectColorView() -> some View {
        return VStack{
            ColorPicker(selection: self.$projectInfo.projectColor,label:{ Text("Color")})
            
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(colorPalette, id: \.self){ colorHex in
                    
                    let color = Color(hex: colorHex)
                    
                    Circle()
                        .foregroundColor(color)
                        .frame(width: 45, height: 45)
                        .opacity(color == self.projectInfo.projectColor ? 0.5 : 1.0)
                        .onTapGesture {
                            self.projectInfo.projectColor = color
                        }
                    
                }
            }
            .padding(.vertical, 30)
        }
    }
    
    fileprivate func doneButtonView() -> some View {
        return HStack{
            Spacer()
            Button(action:   {
                
                if self.editMode  {
                    
                    self.viewModel.editProject(projectId : self.projectInfo.projectId!
                                               ,projectInfo: self.projectInfo)
                    selectedProject = Project(projectName: projectInfo.projectName, projectColor: projectInfo.projectColor, language: projectInfo.selectedLanguage)
                }
                else {
                    self.viewModel.addProject(projectInfo: projectInfo)
                }
                
                self.projectInfo = .init()
                self.showModal = false
                
            }  ) {
                Text("Done")
            } .disabled(self.projectInfo.projectName.isEmpty)
                .alert("Error add project", isPresented: $viewModel.showAlert, actions: {
                    Button("Ok", action: { self.viewModel.showAlert = false })
                }, message: { Text(self.viewModel.error?.localizedDescription ?? "Unknown error") })
            Spacer()
        }
    }
    
    var body: some View {
        VStack(alignment: .leading,spacing: 20){
            
            Form{
                Section{
                    selectProjectNameView()
                }
               
                Section{
                    selectLanguageView()
                }
                
                Section{
                    selectColorView()
                }
                
            }
            
            Spacer()
            
            doneButtonView()
            
        }.background(Color(UIColor.systemGroupedBackground))
       
        
    }
    
    
    
}
