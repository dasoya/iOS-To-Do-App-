//
//  HomeViewModel.swift
//  ios to do app
//
//  Created by dasoya on 18.01.23.
//
import SwiftUI
import Foundation

class HomeViewModel : ObservableObject {
    
    @Published var item = [Project]()
    
    struct addButton: View {
        
        @State private var  showModal = false
      
        var body: some View {
            Button(action:{ self.showModal = true}) {
                Label("Add Item", systemImage: "plus")
            }.sheet(isPresented: $showModal) {
                VStack {
                    Text("Creat a Project")
                        .font(.title)
                    
                    TextField("Project Name", text: item.$projectName)
                    ColorPicker("Project Color", selection: item.$projectColor)
                    
                    Button(action: {
                        // Create a new item with the project name and color entered by the user
                        
                    }) {
                        Text("Add")
                    }
                }.padding(.all,50)
            }
        }
    }
    
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
}
