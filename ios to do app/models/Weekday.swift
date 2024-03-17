//
//  Weekday.swift
//  ios to do app
//
//  Created by Cristi Conecini on 25.01.23.
//

import Foundation

/// An array of string values representing the weekdays of the week
let WEEKDAYS = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

/// A struct representing a weekday, with a weekday number and its corresponding name as properties
struct Weekday {
    // An integer representing the weekday number, where Sunday is 1 and Saturday is 7
    var weekday: Int
    
    // A computed property that returns the name of the weekday as a string
    var name: String {
        WEEKDAYS[self.weekday - 1]
    }
    
    // A date representing the current date
    var date = Date()
    
    /// Initializer that takes a date as a parameter and uses it to set the weekday number and date properties
    ///  - Parameter date: Date to set the weekday number and date properties
    init(from date: Date){
        self.date = date
        self.weekday = Calendar.current.component(.weekday, from: date)
    }
}
