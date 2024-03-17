//
//  FlashcardEditor.swift
//  ios to do app
//
//  Created by User on 16.01.23.
//

import SwiftUI

/// View to add a new Flashcard
struct FlashcardEditor: View {
    @ObservedObject private var flashcard: Flashcard
    @ObservedObject var viewModel: TodoEditorViewModel
    
    /// Creates an instance with the given viewModel.
    ///
    /// - Parameters:
    ///   - viewModel: ViewModel of the Todo
    init (viewModel: TodoEditorViewModel) {
        self.flashcard = Flashcard()
        self.viewModel = viewModel
    }
    
    /// Adds the flashcard to todo
    func saveFlashcard() {
        viewModel.addFlashcard(flashcard: flashcard)
        viewModel.toggleFlashcardEditor()
    }
    var body: some View {
        Form {
            Section {
                TextField("Front", text: $flashcard.front)
                TextField("Back", text: $flashcard.back)
            }
            Button("Save", action: saveFlashcard)
                .disabled(flashcard.front.isEmpty || flashcard.back.isEmpty)
            
        }
        
    }
}


struct FlashcardEditor_Previews: PreviewProvider {
    static var previews: some View {
        FlashcardEditor(viewModel: TodoEditorViewModel())
    }
}
