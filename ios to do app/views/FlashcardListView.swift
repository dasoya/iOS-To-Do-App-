//
//  FlashcardListView.swift
//  ios to do app
//
//  Created by Amit Kumar Shaw on 29.01.23.
//

import SwiftUI

/// View to edit and delete flashcards of a todo
struct FlashcardListView: View {
    
    @ObservedObject var viewModel: TodoEditorViewModel
    
    /// Creates an instance with the given viewModel.
    ///
    /// - Parameters:
    ///   - viewModel: The TodoEditorViewModel to edit and delete flashcards in the todo
    init (viewModel: TodoEditorViewModel) {
        self.viewModel = viewModel
    }
    
    /// Display the list of flashcards available.
    var body: some View {
            VStack {
                List {
                    Section(header: Text("Edit Flashcards")) {
                        ForEach($viewModel.flashcards, id: \.id) {
                            $flashcard in
                            /// Edit front and back of a flashcard directly in TextField.
                            HStack {
                                TextField("Front", text: $flashcard.front)
                                    .textFieldStyle(.roundedBorder)
                                TextField("Back", text: $flashcard.back)
                                    .textFieldStyle(.roundedBorder)
                            }
                        /// Delete a flashcard with swipe gesture.
                        }.onDelete(perform: { viewModel.deleteFlashcard(offsets: $0) })
                    }
                }
            }
            
    }
}

struct FlashcardListView_Previews: PreviewProvider {
    static var previews: some View {
        FlashcardListView(viewModel: TodoEditorViewModel())
    }
}
