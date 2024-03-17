//
//  Project.swift
//  ios to do app
//
//  Created by dasoya on 18.01.23.
//

import Foundation
import CoreData
import SwiftUI



/// Class to represent a project
class Project: ObservableObject, Codable {
    
    /// User ID of the project owner
    @Published var userId: String?

    /// Name of the project
    @Published var projectName: String?

    /// Hexadecimal representation of the project color
    @Published var colorHexString: String?

    /// Language of the project
    @Published var selectedLanguage: Language = Language(id: "en", name: "English", nativeName: "English")

    /// Timestamp of the project creation
    @Published var timestamp: Date?

    /// Coding keys for the properties of the class
    enum CodingKeys: CodingKey {
        
        case userId
        case projectName
        case colorHexString
        case timestamp
        case selectedLanguage
    }

    /// Empty initializer
    init(){
        
    }

    /// Convenient initializer for project name and color
    ///
    /// - Parameters:
    ///   - projectName: The name of the project
    ///   - projectColor: The color of the project
    convenience init(projectName: String?, projectColor: Color?) {
        
           self.init()
        
        if let projectColor = projectColor, let projectName = projectName {
            self.projectName = projectName
            self.colorHexString = projectColor.toHex()
        }
    }

    /// Convenient initializer for project name, color, and language
    ///
    /// - Parameters:
    ///   - projectName: The name of the project
    ///   - projectColor: The color of the project
    ///   - language: The language of the project
    convenience init(projectName: String?, projectColor: Color?, language: Language ) {
        
           self.init()
        
        if let projectColor = projectColor, let projectName = projectName {
            self.projectName = projectName
            self.colorHexString = projectColor.toHex()
            self.selectedLanguage = language
        }
    }

    /// Initializer for decoding the class from a decoder
    ///
    /// - Parameter decoder: The decoder to use
    /// - Throws: Throws an error if the decoding fails
    required init(from decoder: Decoder) throws{
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let isoFormatter = ISO8601DateFormatter()
        
        userId = try values.decode(String.self, forKey: .userId)
        projectName = try values.decode(String.self, forKey: .projectName)
        colorHexString = try values.decode(String.self, forKey: .colorHexString)
        
        let timestampIso = try values.decode(String.self, forKey: .timestamp)
        guard let timestamp = isoFormatter.date(from: timestampIso) else {
            throw DateError()
        }
        self.timestamp = timestamp
      
        selectedLanguage = try values.decode(Language.self, forKey: .selectedLanguage)
       
    }
    
    /// Function for encoding the class
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(projectName, forKey: .projectName)
        try container.encode(colorHexString, forKey: .colorHexString)
        try container.encode(timestamp?.ISO8601Format(), forKey: .timestamp)
        try container.encode(selectedLanguage, forKey: .selectedLanguage)
    
    }
    
       
}


   


