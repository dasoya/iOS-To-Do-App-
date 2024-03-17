//
//  ContentView.swift
//  ios to do app
//
//  Created by Cristi Conecini on 16.01.23.
//

import SwiftUI
/// The View to choose shows homeView or LoginScreen
struct ContentView: View {
    @StateObject var autheniticationViewModel = AuthenticationViewModel()
    var tintColor: Color
    
    init(tintColor: Color){
        self.tintColor = tintColor
    }
    
    var body: some View {
        /// if login then show the HomeView
        if(autheniticationViewModel.isAuthenticated){
            HomeView().tint(tintColor)
        }else{
            LoginScreen().tint(tintColor)
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(tintColor: Color(hex: TINT_COLORS[0]))
    }
}
