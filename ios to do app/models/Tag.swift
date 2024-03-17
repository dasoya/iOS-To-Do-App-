//
//  Tag.swift
//  ios to do app
//
//  Created by Amit Kumar Shaw on 25.01.23.
//

import Foundation
import CoreData
import SwiftUI

/// Model for a Tag
/// - userId: A string representing the user identifier
/// - tag: A string representing the name of the tag
/// - todos: An array of strings, each representing the identifier of a todo associated with this tag
/// - timestamp: A Date representing the creation time of the tag
class Tag: ObservableObject, Codable {
    
    @Published var userId: String?
    @Published var tag: String?
    @Published var todos: [String] = []
    @Published var timestamp: Date?
    
    /// Coding keys for the properties to be used for encoding and decoding
    enum CodingKeys: CodingKey {
        
        case userId
        case tag
        case todoId
        case timestamp
    }
    
    /// Initializes an empty instance of the `Tag` model.
    init(){
        
    }
    
    /// Initializes a new instance of the `Tag` model with the given tag name.
    ///
    /// - Parameter tag: The name of the tag.
    convenience init(tag: String?) {
            self.init()
            self.tag = tag
    }
    
    /// Initializes a new instance of the `Tag` model by decoding data.
    ///
    /// - Parameter decoder: The decoder to use to decode the data.
    required init(from decoder: Decoder) throws{
        let values = try decoder.container(keyedBy: CodingKeys.self)
        userId = try values.decode(String.self, forKey: .userId)
        tag = try values.decode(String.self, forKey: .tag)
        todos = try values.decode([String].self, forKey: .todoId)
        timestamp = try values.decode(Date.self, forKey: .timestamp)
    }
    
    /// Encodes the `Tag` instance into data.
    ///
    /// - Parameter encoder: The encoder to use to encode the data.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(tag, forKey: .tag)
        try container.encode(todos, forKey: .todoId)
        try container.encode(timestamp, forKey: .timestamp)
    }
    
       
}
