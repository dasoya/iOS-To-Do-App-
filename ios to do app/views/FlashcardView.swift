import SwiftUI

/// View to display flashcards of a todo with option to edit and add flashcards
struct FlashcardView: View {
    @Environment(\.tintColor) var tintColor
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var viewModel: TodoEditorViewModel
    @State private var currentCard: Int = 0
    @State private var isFlipped: Bool = false
    @State private var flashcardRotation = 0.0
    @State private var contentRotation = 0.0
    @State private var offset = CGSize.zero
    @State private var showFlashcardEditor: Bool = false
    
    /// Creates an instance with the given viewModel.
    ///
    /// - Parameters:
    ///   - viewModel: The TodoEditorViewModel to display, edit and add flashcards in the todo
    init (viewModel: TodoEditorViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack{
            
            /// Flashcard
            ZStack {
                if self.currentCard < viewModel.flashcards.count - 1 {
                    VStack {
                        
                        Text(viewModel.flashcards[currentCard + 1].front)
                        
                    }
                    
                    .bold()
                    .frame(width: 200, height: 300)
                    .padding()
                    .background(colorScheme == .dark ? .black : .white)
                    .foregroundColor(tintColor)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(tintColor).shadow(radius: 5)
                    )
                }

                VStack {
                    if viewModel.flashcards.isEmpty {
                        Text("No flashcards yet")
                    } else {
                        Text(isFlipped ? viewModel.flashcards[currentCard].back : viewModel.flashcards[currentCard].front)
                    }
                }
                .bold()
                .rotation3DEffect(.degrees(contentRotation), axis: (x: 0, y: 1, z: 0))
                .frame(width: 200, height: 300)
                .padding()
                .background(colorScheme == .dark ? (isFlipped ? tintColor : .black) : (isFlipped ? tintColor : .white))
                .foregroundColor(isFlipped ? .white : tintColor)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(tintColor).shadow(radius: 5)
                )
                .rotationEffect(.degrees(Double(offset.width / 5)))
                .offset(x: offset.width * 5, y: 0)
                .opacity(2 - Double(abs(offset.width / 50)))
                .gesture(
                    DragGesture()
                        .onChanged{ gesture in
                            offset = gesture.translation
                        }
                        .onEnded { _ in
                            if abs(offset.width) > 100 {
                                if self.currentCard < viewModel.flashcards.count - 1 {
                                    isFlipped = false
                                    self.currentCard += 1
                                    
                                }
                                offset = .zero
                            } else {
                                offset = .zero
                            }
                        }
                )
                .onTapGesture {
                    flipFlashcard()
                }
                .rotation3DEffect(.degrees(flashcardRotation), axis: (x: 0, y: 1, z: 0))
            }
            
            Spacer()
            if !viewModel.flashcards.isEmpty {
                VStack {
                    Text("\(self.currentCard + 1)/\(viewModel.flashcards.count)")
                        .foregroundColor(Color.gray)
                    
                }
            }
            
            /// Buttons to flip and move between flashcards
            HStack {
                Button("Previous") {
                    if self.currentCard > 0 {
                        isFlipped = false
                        self.currentCard -= 1
                    }
                }.disabled(self.currentCard == 0 || viewModel.flashcards.isEmpty)
                Spacer()
                Button("Flip") {
                    flipFlashcard()
                }
                .disabled(viewModel.flashcards.isEmpty)
                Spacer()
                Button("Next") {
                    if self.currentCard < viewModel.flashcards.count - 1 {
                        isFlipped = false
                        self.currentCard += 1
                    }
                }.disabled(self.currentCard == viewModel.flashcards.count - 1 || viewModel.flashcards.isEmpty)
            }.padding()
        }.navigationBarTitle("Flashcards")
                        .toolbar {
                            Button(action: {
                                isFlipped = false
                                self.currentCard = 0
                                offset = .zero
                            }) {
                                Text("Reset")
                            }.disabled(viewModel.flashcards.isEmpty)
                            NavigationLink(destination: FlashcardListView(viewModel: viewModel)){
                                Text("Edit")
                            }
                            Button(action: viewModel.toggleFlashcardEditor) {
                                Text("Add")
                            }.sheet(isPresented: $viewModel.showFlashcardEditor) {
                                FlashcardEditor(viewModel: viewModel)
                            }
                            
                        }

    }
    
    /// Flips the flashcard with animation.
    func flipFlashcard() {
            let animationTime = 0.5
        
            /// animate the card flip
            withAnimation(Animation.linear(duration: animationTime)) {
                flashcardRotation += 180
            }
            
            /// flip the card text exactly when the card is perpendicular to screen
            withAnimation(Animation.linear(duration: 0.001).delay(animationTime / 2)) {
                contentRotation += 180
                isFlipped.toggle()
            }
        }
}


struct FlashcardView_Previews: PreviewProvider {
    static var previews: some View {
        FlashcardView(viewModel: TodoEditorViewModel())
    }
}

