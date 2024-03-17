//
// Language.swift
// ios to do app
//
// Created by Cristi Conecini on 15.01.23.
//

import Foundation

/// Model class for a Language.
class Language: Codable{
    /// Unique id of the language.
    var id: String

    /// Name of the language.
    var name: String

    /// Native name of the language.
    var nativeName: String

    /// Initializer that creates a new Language instance.
    ///
    /// - Parameters:
    ///   - id: Unique id of the language.
    ///   - name: Name of the language.
    ///   - nativeName: Native name of the language.
    init(id: String, name: String, nativeName: String) {
        self.id = id
        self.name = name
        self.nativeName = nativeName
    }
}

extension Language {
    /// Returns an array of all languages.
    ///
    /// - Returns: An array of Language instances.
    static func getAllLanguages() -> [Language]{
        let jsonData = JSONUtils.readLocalJSONFile(forName: "languages") ?? Data()
        do{
            let decodedData = try JSONDecoder().decode([Language].self, from: jsonData)
            return decodedData
        }catch{
            print("error decoding json \(error)");
            return []
        }
        
    }
}
extension Language: Hashable, Equatable, Identifiable {
    /// Determines if two Language instances are equal.
    ///
    /// - Parameters:
    ///   - lhs: The first Language instance.
    ///   - rhs: The second Language instance.
    /// - Returns: A boolean indicating if the two instances are equal.
    static func == (lhs: Language, rhs: Language) -> Bool {
        lhs.id == rhs.id
    }

    /// Hashes the unique id of the Language instance.
    ///
    /// - Parameter hasher: A hasher instance.
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}
