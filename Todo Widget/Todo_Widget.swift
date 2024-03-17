//
//  Todo_Widget.swift
//  Todo Widget
//
//  Created by Max on 28.01.23.
//

import WidgetKit
import SwiftUI
import Intents


/// Defines the look and timeline of the Today's Tasks widget
struct Provider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), upcomingTodos: [SimpleTodo(task: "Example task 1", isCompleted: true, color: "#025ee8"), SimpleTodo(task: "Example task 2", isCompleted: true, color: "#18eb09"), SimpleTodo(task: "Example task 3", isCompleted: true, color: "#e802e0"),], configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(SimpleEntry(date: Date(), upcomingTodos: [SimpleTodo(task: "Example task 1", isCompleted: true, color: "#025ee8"), SimpleTodo(task: "Example task 2", isCompleted: true, color: "#18eb09"), SimpleTodo(task: "Example task 3", isCompleted: true, color: "#e802e0")], configuration: ConfigurationIntent()))
    }
    
    /// Calculates the timeline of the widget. Uses the UserDefaults to access the timeline that was provided by the RemindersWidgetAppIconUtil and decodes the json..
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        var jsonString = ""
        if let jS : String = UserDefaults(suiteName: "group.com.iostodoapp")?.string(forKey: "widget_upcoming_days")
        {
            jsonString = jS
        }

        let jsonData = jsonString.data(using: .utf8)!
        
        var decodedUpComingDays = UpcomingDays(dailyTodos: [])
        
        do { decodedUpComingDays = try JSONDecoder().decode(UpcomingDays.self, from: jsonData) }
        catch _ {}
        
        var entries: [SimpleEntry] = []
        
        for day in decodedUpComingDays.dailyTodos {
            
            let entry = SimpleEntry(date:day.date, upcomingTodos: day.dailyTodoList, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}


/// The parent view of the widget
struct Todo_WidgetEntryView : View {
    var entry: Provider.Entry
    var upcomingTodos : [SimpleTodo] = []
    
    init(entry: Provider.Entry) {
        self.entry = entry
    }
    
    var body: some View {
        TodoWidgetView(upcomingTodos: self.entry.upcomingTodos)
    }
}


/// Definition and setup of the widget
struct Todo_Widget: Widget {
    let kind: String = "Todo_Widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            Todo_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Today's Tasks")
        .description("This widget displays all the tasks due for the current day, making it easy to stay on top of your to-do list and get things done.")
    }
}

struct Todo_Widget_Previews: PreviewProvider {
    static var previews: some View {
        Todo_WidgetEntryView(entry: SimpleEntry(date: Date(), upcomingTodos: [], configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}


/// A single time line entry which is presented by the widget
struct SimpleEntry: TimelineEntry {
    var date: Date
    let upcomingTodos : [SimpleTodo]
    let configuration: ConfigurationIntent
}


/// The parent JSON-object which is used for decoding the timeline provided by the RemindersWidgetAppIconUtil
struct UpcomingDays: Decodable {
    let dailyTodos: [DailyTodo]
}


/// Used to describe the todos for a single day
struct DailyTodo: Decodable {
    let date: Date
    let dailyTodoList: [SimpleTodo]
}


/// Simplified version of a ToDo that only consists of a task, whether it is completed or not and the user selected accent color of the checkmark
struct SimpleTodo: Decodable {
    let task : String
    let isCompleted : Bool
    let color : String
}
