//
//  TodoView.swift
//  ios to do app
//
//  Created by Shivam Singh Rajput on 10.01.23.
//

import Foundation
import SwiftUI


struct TodoView: View {
    @ObservedObject var todoListViewModel = TodoListViewModel()
    @State var project : (String, Project)
    @State private var showFlashcardEditor: Bool = false
           
    
    @State var showCard = false
    @Environment(\.presentationMode) var presentationMode
    
    @State var selectedFilter: FilterType = .all
    

    var body: some View {
            VStack {
                HStack(alignment: .bottom) {
                    if let name = self.project.1.projectName {
                        Text(name)
                            .font(.system(size: 50, weight: .ultraLight, design: .rounded))
                            .frame(width: UIScreen.main.bounds.width * 0.6)
                    }
                    VStack {
                        Text("\(Int(todoListViewModel.progress * 100))%")
                            .font(.system(size: 50, weight: .ultraLight, design: .rounded))
                        Text("completed")
                            .font(.system(size: 18, design: .rounded))
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.3)
                }.padding()
                
                TodoList(nil,selectedFilter, self.project.0).listStyle(.inset).toolbar(){
                    ToolbarItem(placement: .automatic) {
                        EditButton()
                    }
                }
                HStack {
                    Picker(selection: $selectedFilter, label: Text("Filter"), content: {
                        ForEach(FilterType.allCases, id: \.self) { v in
                            Text(v.localizedName).tag(v)
                        }
                    })
                    Spacer()
                    NavigationLink {
                        CreateTodoView(projectId :project.0)
                    } label: {
                        Text("Add")
                    }
                }.padding(.horizontal, 20)
            }
    }
}



struct TodoView_Previews: PreviewProvider {
    static var previews: some View {
        TodoView(project: ("",Project(projectName: "Preview", projectColor: Color.brown)))
    }
}
