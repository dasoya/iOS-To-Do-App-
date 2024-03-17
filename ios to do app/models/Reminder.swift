//
//  Reminder.swift
//  ios to do app
//
//  Created by Cristi Conecini on 15.01.23.
//

import Foundation

class Reminder: Identifiable, ObservableObject, Codable {
    /// `id` is the identifier for the reminder object, generated as a unique string
    @Published var id = UUID().uuidString
    /// `date` is the date when the reminder will occur
    @Published var date: Date = Date()
    
    enum CodingKeys: CodingKey {
        case id
        case date
    }
    
    /// Initializer with no parameters, generates a unique identifier for the reminder object
    init(){
    }
    
    /// Initializer with date parameter, sets the `date` of the reminder object
    init(date: Date) {
        self.date = date
    }
    
    /// Initializer from decoder, used to decode reminder objects from data
    required init(from decoder: Decoder) throws {
        let isoFormatter = ISO8601DateFormatter()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let dateIso = try values.decode(String.self, forKey: .date)
        guard let date = isoFormatter.date(from: dateIso) else {
            throw DateError()
        }
        self.date = date
        
        id = try values.decode(String.self, forKey: .id)
    }
    
    /// Function to encode reminder object to data
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date.ISO8601Format(), forKey: .date)
    }
}

extension Reminder: Equatable, Hashable{
    /// Function to compare two reminders to check if they are equal, returns a boolean value indicating equality
    static func == (lhs: Reminder, rhs: Reminder) -> Bool {
        lhs.id == rhs.id
    }
    /// Function to generate a hash value for the reminder object, used for hashing
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id);
    }
}
