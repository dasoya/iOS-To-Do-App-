//
//  LanguageList.swift
//  ios to do app
//
//  Created by Cristi Conecini on 15.01.23.
//

import SwiftUI

/// Language List
struct LanguageList: View {
    /// State property `languages` to get all the language from swift API
    @State var languages: [Language] = Language.getAllLanguages()
    
    var body: some View {
        ForEach(languages, id: \.id) { language in
                Text(language.name).tag(language)
            }
    }
}

struct LanguageList_Previews: PreviewProvider {
    static var previews: some View {
        LanguageList()
    }
}
