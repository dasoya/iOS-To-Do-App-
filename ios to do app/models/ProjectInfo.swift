//
//  ProjectInfo.swift
//  ios to do app
//
//  Created by dasoya on 30.01.23.
//

import Foundation
import SwiftUI


/// Project Info to store values gotten by user  for creating a project
struct ProjectInfo {
    
    // name of the project
    var projectName : String

    // color of the project
    var projectColor : Color

    // selected language for the project
    var selectedLanguage : Language

    // id of the project
    var projectId : String?
    
    init(){
        projectName = ""
        projectColor = Color.white
        selectedLanguage = Language(id: "en", name: "English", nativeName: "English")
       
    }
    
    /// Initialize ProjectInfo with specific values
    ///
    /// - Parameters:
    ///   - id: id of the project
    ///   - name: name of the project
    ///   - color: color of the project
    ///   - language: selected language for the project
    init(id : String ,name:String,color:Color,language:Language){
        self.init()
        projectId = id
        projectName = name
        projectColor = color
        selectedLanguage = language
   
    }
    
    /// Initialize ProjectInfo with a tuple of id and project
    ///
    /// - Parameter project: tuple of id and project
    init(project : (String, Project)){
        
        projectId = project.0
        projectName = project.1.projectName!
        projectColor = Color(hex:project.1.colorHexString!)
        selectedLanguage = project.1.selectedLanguage
    }
    
    
}

