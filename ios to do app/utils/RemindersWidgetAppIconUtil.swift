//
//  RemindersWidgetAppIconUtil.swift
//  ios to do app
//
//  Created by Max on 20.01.23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import NotificationCenter
import Foundation
import WidgetKit


/// This struct offers a set of functionalities related to scheduling notifications, providing data for the timeline of the widget, and changing the app icon dynamically.
struct RemindersWidgetAppIconUtil{
    
    /// Opens the app settings page of the app.
    public static func openSettings() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
            UIApplication.shared.open(appSettings)
        }
    }
    
    
    /// Increments the count of times the reminder modal has appeared.
    public static func incrementReminderModalAppearanceCount() {
        let defaults = UserDefaults.standard
        var count = RemindersWidgetAppIconUtil.getReminderModalAppearanceCount()
        count += 1

        defaults.set(count, forKey: "reminderModalAppearanceCount")

    }
    
    /// Retrieves the count of times the reminder modal has appeared.
    /// - Returns: The count of times the reminder modal has appeared.
    public static func getReminderModalAppearanceCount() -> Int {
        let defaults = UserDefaults.standard
        if let count = defaults.value(forKey: "reminderModalAppearanceCount") as? Int {

            return count
        } else {
            defaults.set(0, forKey: "reminderModalAppearanceCount")
            return 0
        }
    }
    
    /// Retrieves the user's preference for not showing the reminders modal.
    /// - Returns: false if the user shouldn't see the reminders modal in general again; true otherwise
    public static func getDontShowRemindersModal() -> Bool {
        if UserDefaults.standard.value(forKey: "dontShowRemindersModal") == nil {
            UserDefaults.standard.set(false, forKey: "dontShowRemindersModal")
        }
        return UserDefaults.standard.bool(forKey: "dontShowRemindersModal")
    }
    
    /// Sets the user's preference for not showing the reminders modal.
    public static func setDontShowRemindersModal() {
        UserDefaults.standard.set(true, forKey: "dontShowRemindersModal")
    }
    

    
    /// Determines if the user has granted notifications permissions.
    /// - Parameter completion: A closure that is called with the result of the check. The closure is passed a `Bool` indicating whether the user has granted notifications permissions (`true`) or not (`false`).
    public static func hasPermissions(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    /// Indicates whether the app has previously asked the user for notifications permissions.
    /// - Returns: `true` if the app has previously asked the user for notifications permissions; `false` otherwise.
    public static func didAskForNotificationPermissions() -> Bool {
        if UserDefaults.standard.value(forKey: "didAskForNotificationPermissions") == nil { // 1
            UserDefaults.standard.set(false, forKey: "didAskForNotificationPermissions") // 2
        }
        return UserDefaults.standard.bool(forKey: "didAskForNotificationPermissions")
    }
    
    /// Requests the user for notification permissions.
    public static func askForNotificationPermissions() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            
            if let _ = error {
                // Handle the error here.
                return
            }
            UserDefaults.standard.set(true, forKey: "didAskForNotificationPermissions")

            // Enable or disable features based on the authorization.
        }
    }
    
    /// Returns the reminder description in minutes, hours or days.
    /// - Parameter minutes: The number of minutes before due date to remind the user.
    /// - Returns: The reminder description string in minutes, hours or days.
    public static func getRemindMeBeforeDueDateDescription(minutes : Int) -> String {
        let _minutes = minutes > 0 ? minutes : -minutes
        
        if (_minutes < 60) {
            return "\(_minutes) \(_minutes > 1 ? "minutes" : "minute")"
        }
        if (minutes < 1440) {
            return "\(_minutes / 60) \((_minutes / 60) > 1 ? "hours" : "hour")"
        }

        return "\(_minutes / 1440) \((_minutes / 1440) > 1 ? "days" : "day")"
        
    }
    
    /// Retrieves the list of to-dos and returns it as an array of tuples containing the to-do-id and the to-do object. The result is passed to the completion closure as an argument.
    /// - Parameter completion: A closure that takes in an array of tuples, each containing a String as the to-do id and a Todo object
    static func getTodoList(completion: @escaping ([(String, Todo)]) -> Void) {
        let db = Firestore.firestore()
        let auth = Auth.auth()

        guard let currentUserId = auth.currentUser?.uid else {
            completion([])
            return
        }

        let userTodosQuery = db.collection("todos").whereField("userId", in: [currentUserId])
        userTodosQuery.addSnapshotListener { querySnapshot, error in
            if error != nil {
                completion([])
                return
            }

            do {
                let docs = try querySnapshot?.documents.map({ docSnapshot in
                    return (docSnapshot.documentID, try docSnapshot.data(as: Todo.self))
                })
                let todoList: [(String, Todo)] = docs!

                completion(todoList)
            } catch {
                completion([])
            }
        }
    }
    
    //// Schedules a single reminder with a given date, title, and body
    /// - Parameters:
    ///     - date: The date when the reminder should trigger
    ///     - title: The title of the reminder
    ///     - body: The message of the reminder
    ///     - todoId: The id of the todo the notification belongs to
    private static func scheduleSingleReminder(date : Date, title: String, body: String, todoId: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.userInfo = ["todoId": todoId]
    
        
        if (date.timeIntervalSinceNow.isLessThanOrEqualTo(0)) {
            // already in the past
            return
        }
      
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: date.timeIntervalSinceNow, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.day, .hour, .minute, .second]
                formatter.unitsStyle = .abbreviated

                let formattedInterval = formatter.string(from: date.timeIntervalSinceNow)
              
            }
        }
    }
    
    /// Schedules reminders for a given list of todos
    /// - Parameter todoList: An array of tuples consisting of entity id and todo object
    private static func scheduleReminders(todoList: [(String, Todo)]) {
        // Remove all scheduled notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        for (entityId, todo) in todoList {
            
            if todo.isCompleted {
                continue
            }
            
            if todo.reminderBeforeDueDate >= 0, let timeInterval = TimeInterval(exactly: -todo.reminderBeforeDueDate * 60) {
         
                self.scheduleSingleReminder(date: todo.dueDate.addingTimeInterval(timeInterval), title: todo.task, body: todo.description, todoId: entityId)
                
                // only schedule future recurring reminders if no cloned recurring todo already exists:
                if !todoList.contains(where: {(_, todo) in
                    todo.createdByRecurringTodoId == entityId
                }) {
                    if (todo.recurring != .none) {
                        if (todo.recurring != .monthly) {
                            // calculate 7 days/weeks in the future
                            for i in 1...7 {
                                
                                if let recurringInterval = TimeInterval(exactly: 60 * 60 * 24 * (todo.recurring == .daily ? 1 : 7) * i) {
                                    self.scheduleSingleReminder(date: todo.dueDate.addingTimeInterval(recurringInterval), title: todo.task, body: todo.description, todoId: entityId)
                                }
                            }
                        } else {
                            let calendar = Calendar.current
                            // calculate 6 months
                            for i in 1...6 {
                                
                                if let iMonthsLater = calendar.date(byAdding: .month, value: i, to: todo.dueDate) {
                                    self.scheduleSingleReminder(date: iMonthsLater, title: todo.task, body: todo.description, todoId: entityId)
                                }
                            }
                        }
                        
                    }
                }
                
            }
            for reminder in todo.reminders {
                self.scheduleSingleReminder(date: reminder.date, title: todo.task, body: todo.description, todoId: entityId)
            }
        }
    }
    
    ///  Takes a list of todos and calculates the timeline for the widget for today and the next 7 days. It encodes the timeline as JSON and saves it using UserDefaults and AppGroups so that the WidgetTimeLineProvider can decode it again.
    /// - Parameters:
    ///   - tintColor: the accent color that got selected by the user
    ///   - todoList: list of all todos which should be displayed in the widget
    static func provideWidgetTimeline(tintColor: String, todoList: [(String, Todo)]) {
        
      var dailyTodosTuple : [(Date, [SimpleTodo])] = []
        
      let calendar = Calendar.current
      let now = calendar.startOfDay(for:  Date())
        
      dailyTodosTuple.append((now, []))
    
       for i in 1...7 {
           let date = calendar.date(byAdding: .day, value: i, to: now)!
           let startOfDay = calendar.startOfDay(for: date)
           dailyTodosTuple.append((startOfDay, []))
       }
        
        
        for (_, todo) in todoList {
            
            for i in 0 ..< dailyTodosTuple.count {
                
                var (dailyTodoDate, dailyTodoTodos) : (Date, [SimpleTodo]) = dailyTodosTuple[i]
                
                if todo.dueDate >= dailyTodoDate && todo.dueDate <= calendar.date(byAdding: .day, value: 1, to: dailyTodoDate)! {
                    dailyTodoTodos.append(SimpleTodo(task: todo.task, isCompleted: todo.isCompleted, color: "\(tintColor)"))
                    dailyTodosTuple[i] = (dailyTodoDate, dailyTodoTodos)
                    break
                }
            }
            
        }
        
        var dailyTodos : [DailyTodo] = []
        
        for (dayDate, dayTodos) in dailyTodosTuple {
            
            let sortedTodos = dayTodos.sorted(by: {(lhs, rhs) in
                !lhs.isCompleted
            })
            
           
            dailyTodos.append(DailyTodo(date: dayDate, dailyTodoList: sortedTodos))
        }
        
        let upComingDays = UpcomingDays(dailyTodos: dailyTodos)
        
        do {
            let jsonData = try JSONEncoder().encode(upComingDays)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            
            if let defaults = UserDefaults(suiteName: "group.com.iostodoapp") {
                defaults.setValue(jsonString, forKey: "widget_upcoming_days")

            }
        } catch {
            print(error)
        }
        
        WidgetCenter.shared.reloadAllTimelines()

    }

    
    /// Schedules reminders and updates the timeline of the widget. Uses directly the Firestore to retrieve all relevant todos.
    /// - Parameter tintColor: the accent color that got selected by the user
    static func scheduleRemindersAndWidgetTimeline(tintColor : String) async {
        
        getTodoList(completion: {todoList in
            
            // schedule notifications if possible
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                if settings.authorizationStatus == .authorized {
                    // The user has granted permission to send notifications
                    print("Has permissions to send notifications")
                    self.scheduleReminders(todoList: todoList)
                }
                
                else {
                    print("No permissions to send notifications")
                }
            }
            
            // provide timeline for today-widget
            provideWidgetTimeline(tintColor: tintColor, todoList: todoList)
            
        })
        
    }
    
    /// Sets the app icon. The new icon reflects the specified tint color, theme and whether all todos are completed for the current day
    /// - Parameters:
    ///   - tintColor: A String representing the tint color for the app icon.
    ///   - themePrefix: A String representing the theme of the device (either 'Dark' or 'Light')
    static func setAppIcon(tintColor: String, themePrefix: String) async {
        
        getTodoList(completion: {todoList in
            var isDayCompleted = true
            
            for (_, todo) in todoList {
                if todo.dueDate >= Calendar.current.startOfDay(for:  Date()) && todo.dueDate <= Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for:  Date()))! {
                    if (!todo.isCompleted) {
                        isDayCompleted = false
                        break
                    }
                }
            }
            self.determineFileNameAndSetAppIcon(tintColor: tintColor, isTodayNotCompleted: !isDayCompleted, themePrefix: themePrefix)
            
        })
       
    }
    
    /// Determines the file name of the desired icon based on the given tint color, today's completion status, and theme. The determined file is then set as the app icon using the setApplicationIconName function. Makes also sure that the app icon is only set if it actually changes.
    /// - Parameters:
    ///   - tintColor: A String representing the tint color for the app icon.
    ///   - isTodayNotCompleted: A Bool indicating whether today's to-dos have been completed or not.
    ///   - themePrefix:  A String representing the prefix for the theme applied to the app icon.
    private static func determineFileNameAndSetAppIcon(tintColor: String, isTodayNotCompleted : Bool, themePrefix : String) {
        
        var iconSuffix = "BlueUntickedIcon"
        
        if tintColor.lowercased() == "#007aff" {
            // blue
            if (isTodayNotCompleted) {
                iconSuffix = "BlueUntickedIcon"
            } else {
                iconSuffix = "BlueTickedIcon"
            }
           
        }
        if tintColor.lowercased() == "#18eb09" {
            // green
            if (isTodayNotCompleted) {
                iconSuffix = "GreenUntickedIcon"
            } else {
                iconSuffix = "GreenTickedIcon"
            }
        }
        if tintColor.lowercased() == "#e802e0" {
            // "pink"
            if (isTodayNotCompleted) {
                iconSuffix = "PinkUntickedIcon"
            } else {
                iconSuffix = "PinkTickedIcon"
            }
        }
        if tintColor.lowercased() == "#eb7a09" {
            // orange
            if (isTodayNotCompleted) {
                iconSuffix = "OrangeUntickedIcon"
            } else {
                iconSuffix = "OrangeTickedIcon"
            }
        }
        
        let iconName : String = "\(themePrefix)\(iconSuffix)"

        let lastAppIconName = UserDefaults.standard.string(forKey: "lastAppIconName") ?? "DarkBlueTickedIcon"

        if iconName != lastAppIconName {
            DispatchQueue.main.async {
                self.setApplicationIconName(iconName)
            }
            UserDefaults.standard.set(iconName, forKey: "lastAppIconName")
        }
        
    }
    
    /// Sets the app icon to the desired file named iconName using a private Apple API. Using the standard way to set the app's icon would trigger an alert each time the icon is set, but this way allows the icon to be set without triggering an alert.
    /// - Parameter iconName: A String representing the name of the file to be set as the app icon.
    private static func setApplicationIconName(_ iconName: String) {
        if UIApplication.shared.responds(to: #selector(getter: UIApplication.supportsAlternateIcons)) && UIApplication.shared.supportsAlternateIcons {
            
            typealias setAlternateIconName = @convention(c) (NSObject, Selector, NSString, @escaping (NSError) -> ()) -> ()
            
            let selectorString = "_setAlternateIconName:completionHandler:"
            
            let selector = NSSelectorFromString(selectorString)
            let imp = UIApplication.shared.method(for: selector)
            let method = unsafeBitCast(imp, to: setAlternateIconName.self)
            method(UIApplication.shared, selector, iconName as NSString, { _ in })
        }
    }
    
}


/// The parent JSON-object which is used for encoding the timeline
struct UpcomingDays: Decodable, Encodable {
    let dailyTodos: [DailyTodo]
}

/// Used to describe the todos for a single day
struct DailyTodo: Decodable, Encodable {
    let date: Date
    var dailyTodoList: [SimpleTodo]
}

/// Simplified version of a ToDo that only consists of a task, whether it is completed or not and the user selected accent color of the checkmark
struct SimpleTodo: Decodable, Encodable {
    let task : String
    let isCompleted : Bool
    let color : String
}
