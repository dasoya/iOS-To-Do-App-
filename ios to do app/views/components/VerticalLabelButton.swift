//
//  VerticalLabelButton.swift
//  ios to do app
//
//  Created by Cristi Conecini on 30.01.23.
//

import SwiftUI


///A Button showing an icon and a title in a vertical displacement
/// - Parameters:
///    - title: Title of the button
///    - systemImage: Name of the system icon to be displayed
///    - action: closure triggered on click of the button
struct VerticalLabelButton: View {
    
    var action: () -> Void
    var title: String
    var systemImage: String
    
    /// - Parameters:
    ///    - title: Title of the button
    ///    - systemImage: Name of the system icon to be displayed
    ///    - action: closure triggered on click of the button
    init(_ title: String, systemImage: String ,action: @escaping () -> Void){
        self.title = title
        self.action = action
        self.systemImage = systemImage
    }
    
    
    var body: some View {
        Button(action: action){
            VStack{
                Image(systemName: systemImage)
                Text(title).font(.caption)
            }
        }

    }
}

struct VerticalLabelButton_Previews: PreviewProvider {
    static var previews: some View {
        VerticalLabelButton("Veeeeery long Title", systemImage: "bell", action: {})
    }
}
