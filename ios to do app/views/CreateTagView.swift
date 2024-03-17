//
//  CreateTagView.swift
//  ios to do app
//
//  Created by Amit Kumar Shaw on 25.01.23.
//

import SwiftUI

/// View to create a Tag
struct CreateTagView: View {
    @Environment(\.tintColor) var tintColor

    @Binding private var showModal: Bool
    @State private var tag = ""
    private var todo: String?
    @ObservedObject private var viewModel: TagViewModel
    
    /// Creates an instance.
    ///
    /// - Parameters:
    ///   - show: Used to make the view appear or disappear
    init(show: Binding<Bool>) {
        viewModel = TagViewModel()
        self._showModal = show
    }
    
    /// Creates an instance.
    ///
    /// - Parameters:
    ///   - todoId: To create a tag and add it to this todo
    ///   - show: Used to make the view appear or disappear
    init(todoId: String, show: Binding<Bool>) {
        viewModel = TagViewModel()
        self.todo = todoId
        self._showModal = show
    }
    
    var body: some View {
        VStack{
            HStack {
                TextField("Tag", text: self.$tag)
                
                Spacer()
                
                Text("Cancel")
                    .onTapGesture {
                        showModal = false
                        self.tag = ""
                    }
                    .foregroundColor(tintColor)
            }
            HStack {
                Text("Create Tag")
                    .onTapGesture {
                        self.viewModel.addTag(tag: self.tag, todo: self.todo)
                        showModal = false
                        self.tag = ""
                    }.foregroundColor(self.tag.isEmpty ? .gray : tintColor)
                    .disabled(self.tag.isEmpty)
                    .alert("Error add tag", isPresented: $viewModel.showAlert, actions: {
                        Button("Ok", action: { self.viewModel.showAlert = false })
                    }, message: { Text(self.viewModel.error?.localizedDescription ?? "Unknown error") })
                
            }
        }
    }
}

struct CreateTagView_Previews: PreviewProvider {
    static var previews: some View {
        CreateTagView(show: .constant(false))
    }
}
