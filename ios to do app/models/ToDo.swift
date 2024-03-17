//
//  Todo.swift
//  ios to do app
//
//  Created by Cristi Conecini on 14.01.23.
//

import Foundation
import Combine
import SwiftUI

class Todo: ObservableObject, Codable{
    
    /// Holds the selected language
      @Published var selectedLanguage: Language = Language(id: "en", name: "English", nativeName: "English")
      
      /// Holds the description of the task
      @Published var description = ""
      
      /// Start date of the task
      @Published var startDate = Date()
      
      /// Due date of the task
      @Published var dueDate = Date()
      
      /// Remind before due date in minutes; default: 5 minutes, negative value indicates no reminder
      @Published var reminderBeforeDueDate : Int = 5
      
      /// An array of reminders for the task
      @Published var reminders: [Reminder] = []
      
      /// Priority of the task, with values - .high, .medium, .low
      @Published var priority: Priority = .medium
      
      /// Recurring frequency of the task, with values - .none, .daily, .weekly, .monthly, .yearly
      @Published var recurring: Recurring = .none
      
      /// An array of flashcards associated with the task
      @Published var flashcards : [Flashcard] = []
      
      /// Boolean indicating if the task is completed
      @Published var isCompleted = false
      
      /// Name of the task
      @Published var task = ""
      
      /// User id who created the task
      @Published var userId: String?
      
     
      
      /// Project id to which the task is associated
      @Published var projectId: String?
      
      /// Id of the recurring task from which this task is created
      @Published var createdByRecurringTodoId : String = ""
    
    enum CodingKeys: CodingKey {
        case selectedLanguage
        case description
        case flashcards
        case startDate
        case dueDate
        case reminderBeforeDueDate
        case reminders
        case priority
        case recurring
        case isCompleted
        case task
        case userId
        case projectId
        case createdByRecurringTodoId
    }
    
    init(){
        
    }
/// Initialize a Todo from a decoder
    required init(from decoder: Decoder) throws {
        /// An ISO8601 formatter to parse dates
        let isoFormatter = ISO8601DateFormatter()
        
        /// Get the values from the decoder
        let values = try decoder.container(keyedBy: CodingKeys.self)
        selectedLanguage = try values.decode(Language.self, forKey: .selectedLanguage)
        description = try values.decode(String.self, forKey: .description)
        let startDateISO = try values.decode(String.self, forKey: .startDate)
        let dueDateISO = try values.decode(String.self, forKey: .dueDate)
        
        
        
        /// Parse the start date from ISO8601 format
        guard let startDate = isoFormatter.date(from: startDateISO) else {
            throw DateError()
        }
        /// Parse the due date from ISO8601 format
        guard let dueDate = isoFormatter.date(from: dueDateISO) else {
            throw DateError()
        }
        
        self.startDate = startDate
        self.dueDate = dueDate
        
        reminderBeforeDueDate = try values.decode(Int.self, forKey: .reminderBeforeDueDate)
        flashcards = try values.decode([Flashcard].self, forKey: .flashcards)
        reminders = try values.decode([Reminder].self, forKey: .reminders)
        priority = try values.decode(Priority.self, forKey: .priority)
        recurring = try values.decode(Recurring.self, forKey: .recurring)
        isCompleted = try values.decode(Bool.self, forKey: .isCompleted)
        task = try values.decode(String.self, forKey: .task)
        userId = try values.decode(String.self, forKey: .userId)
        projectId = try values.decode(String.self, forKey: .projectId)
        createdByRecurringTodoId = try values.decode(String.self, forKey: .createdByRecurringTodoId)
    }
    
    convenience init(selectedLanguage: Language){
        self.init()
        self.selectedLanguage = selectedLanguage
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(selectedLanguage, forKey: .selectedLanguage)
        try container.encode(flashcards, forKey: .flashcards)
        try container.encode(description, forKey: .description)
        try container.encode(startDate.ISO8601Format(), forKey: .startDate)
        try container.encode(dueDate.ISO8601Format(), forKey: .dueDate)
        try container.encode(reminderBeforeDueDate, forKey: .reminderBeforeDueDate)
        try container.encode(reminders, forKey: .reminders)
        try container.encode(priority, forKey: .priority)
        try container.encode(recurring, forKey: .recurring)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(task, forKey: .task)
        try container.encode(userId, forKey: .userId)
        try container.encode(projectId, forKey: .projectId)
        try container.encode(createdByRecurringTodoId, forKey: .createdByRecurringTodoId)
        
    }   
}


enum Priority: String, CaseIterable, Equatable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var localizedName: LocalizedStringKey {LocalizedStringKey(rawValue)}
}

enum Recurring: String, CaseIterable, Equatable, Codable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    
    var localizedName: LocalizedStringKey {LocalizedStringKey(rawValue)}
}



enum FilterType: String, CaseIterable, Equatable{
    
    case all = "All"
    case completed = "Completed"
    case incomplete = "Incomplete"
    
    var localizedName: LocalizedStringKey {LocalizedStringKey(rawValue)}
}

