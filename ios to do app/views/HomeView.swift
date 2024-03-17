//
//  ContentView.swift
//  ios to do app
//
//  Created by Cristi Conecini on 04.01.23.
//

import CoreData
import FirebaseAuth
import SwiftUI


/// The HomeView is the main landing page for a user after a successful login. This View struct mainly encapsulates the SearchableView that describes all the components visible on the home view.
struct HomeView: View {
    //State variable to hold the search text entered by the user
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            SearchableView(searchText:$searchText)
        }
        // Adds a search bar to the navigation bar
        .searchable(text: $searchText)
        .disableAutocorrection(true)
    }
    
}

/// The SearchableView struct holds all the components visible on the home screen and provides a search functionality for users to search for projects or todos directly from the home screen.
struct SearchableView: View {
    
    @Environment(\.tintColor) var tintColor
    @EnvironmentObject var notificationsNavManager: NotificationNavigationManager
    
    
    @State private var offset: CGFloat = 0
    @State private var searchTerm = ""
    @State private var showModal = false
    
    ///State property `languageProjectDict` is a dictionary for sorting projects by their language
    @State private var languageProjectDict = [String:[(String,Binding<Project?>)]]()
    
    @State var showTodayView : Bool = false
    @State var isSortedByLanguage = false
    @State var projectForBinding : Project? = Project()
    
    @Binding public var searchText : String
    
    ///Observed object property  `View Model`  to load projects list and their info
    @ObservedObject var viewModel = ProjectViewModel()
    
    @Environment(\.isSearching) private var isSearching
    @Environment(\.dismissSearch) private var dismissSearch
    
    init(searchText : Binding<String>){
        
        self._searchText = searchText
        
    }
    
    
    /// Returns a View that displays a navigation link to the UpcomingView with an hourglass icon and "Upcoming" text in the specified tintColor.
    /// - Returns: A View that displays a navigation link to the UpcomingView.
    fileprivate func upcomingList() -> some View {
        return HStack {
            NavigationLink(destination: UpcomingView(), label: {
                Image(systemName: "hourglass.circle.fill").foregroundColor(tintColor)
                Text("Upcoming")
            })
        }
    }
    
    /// Returns a View that displays a navigation link to the TodayView with a calendar icon and "Today" text in the specified tintColor. When a deep link with the "widget-deeplink" scheme is opened, the showTodayView binding is set to true.
    /// - Returns: A View that displays a navigation link to the TodayView and handles deep links.
    fileprivate func todayList() -> some View{
        return HStack {

            
            NavigationLink(destination: TodayView(),
                           isActive: $showTodayView,
                           label: {
                Image(systemName: "calendar.badge.exclamationmark").foregroundColor(tintColor)
                Text("Today")
            })
        }.onOpenURL{ url in
            guard url.scheme == "widget-deeplink" else { return }
            showTodayView = true
        }.onReceive(notificationsNavManager.$pageToNavigateTo) { v in
            if(v == "today"){
                showTodayView = true
                notificationsNavManager.pageToNavigateTo = nil
            }
            
        }
    }
    
    /// Link to Tags filter View
    /// - Returns: A cell to access Tags filter view
    fileprivate func tagList() -> some View{
        return HStack {
            NavigationLink(destination: TagView(),
                           label: {
                Image(systemName: "number.square.fill").foregroundColor(tintColor)
                Text("Tags")
            })
        }
    }
    
    /// Function projectList displays a list of projects by navigating to ProjectListView
    /// - Parameters:
    ///     Inputs  : $viewModel.projects - an array of tuple representing projects
    /// - Returns: A list of project names each linked to its respective ProjectListView
    fileprivate func projectList() -> some View {
        return ForEach($viewModel.projects, id: \.0) { $item in
            // navigate to Project to do list
            NavigationLink(destination: ProjectListView(projectId: item.0)) {
                
                //show a project list
                ProjectListRow(project: (item.0, $item.1),isSortedByLanguage : $isSortedByLanguage)
                
            }
        }
        .headerProminence(.standard)
    }

    
    /// This viewbuilder uses all functions declared above and builds the final HomeView
    @ViewBuilder var body: some View {
        
        List {
            if (!isSearching) {
                
                todayList()
                
                upcomingList()
                
                tagList()
                
                if self.isSortedByLanguage {
                    /// Projects Section sorted by language
                    sortByLanguage()
                    
                } else {
                        
                    /// Projects Section
                    Section {
                        
                        if viewModel.projects.isEmpty { addButton
                        } else {
                            projectList()
                        } }header: {
                            Text("Projects").foregroundColor(tintColor).font(.headline)
                        }
                    
                }
            }
            else {
                SearchView(searchText: $searchText)
            }
        
        }
        
        .toolbar {
            ToolbarItem(placement: .automatic) {
                
                sortByLanguageButton
            }
            ToolbarItem(placement: .automatic) {
                addButton
            }
            ToolbarItem(placement: .automatic) {
                settingButton
            }
            
        }
        .navigationTitle("Welcome")
        .padding(.zero)
        
        
        
    }
    

   
    
    ///Creates a button that opens a modal view to add a new project.
    private var addButton: some View {
        return AnyView(
            Button(action: { self.showModal = true }) {
                Label("Add Item", systemImage: "plus")
            }.sheet(isPresented: $showModal) {
                CreateProjectView(project: $projectForBinding, showModal: $showModal)
            }
        )
    }
    
    ///Displays a button that allows the user to access and change app settings such as color scheme.
    fileprivate var settingButton : some View {
        return HStack {
            NavigationLink(destination: SettingsView(), label: {
                Image(systemName: "gearshape").foregroundColor(tintColor)
                
            })
        }
    }
    
    ///Sorts and saves the projects by their selected language in a dictionary called languageProjectDict.
    ///The dictionary uses the language name as the key and a tuple of project ID and project information as the value.
    func saveLanguageDict(){
        
        languageProjectDict = [:]
        
        for item in $viewModel.projects {
            
            let key = item.1.wrappedValue?.selectedLanguage.name ?? "None"
            let value = (item.0.wrappedValue,item.1.self)
            
            
            if var projects = languageProjectDict[key] {
                projects.append(value)
                languageProjectDict[key] = projects
            } else {
                languageProjectDict[key] = [value]
            }
            
        }
        
    }
    
    /// Returns a button that sorts the list of items by language when pressed.
    private var sortByLanguageButton : some View {
        
        return AnyView(
            Button(action: {
                saveLanguageDict()
                isSortedByLanguage = !isSortedByLanguage }) {
                    Label("SortByLanguage", systemImage: "tray.fill")
                }
        )
        
    }
    
    
    /// This function returns a grouped view of project lists sorted by language. The view consists of multiple sections, each section contains the projects with the same language, represented by the header and the list of project names in the form of NavigationLink, which redirects to the detailed ProjectListView when clicked.
    /// - Returns: A view showing a sorted list of projects based on the selected language
    private func sortByLanguage() -> some View {

        var languageListsViews = [AnyView]()

        languageProjectDict.forEach{ language, values in

            let section = Section(header: Text(language)){

                ForEach(values, id:\.0){ value in

                    NavigationLink(destination: ProjectListView(projectId: value.0) ){

                        //show a project list
                        ProjectListRow(project: (value.0, value.1), isSortedByLanguage : $isSortedByLanguage)

                    }
                }
            }
            languageListsViews.append(AnyView(section))

        }
        
        
        return Group {

            ForEach(0...languageListsViews.count-1,id: \.self) { index in
                languageListsViews[index]
            }

        }
    }
    
 
    
   
}



struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
