//
//  ContentView.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 21/04/2026.
//

import SwiftUI

struct ContentView: View {
    @State var loginVM = LoginViewModel()

    var body: some View {
        
        if loginVM.currentUser != nil {
            if loginVM.currentUser?.accountStatus == 1 {
                LandingPageView()
                    .environment(loginVM)
            } else if loginVM.currentUser?.accountStatus == 0 {
                OnBoarding1()
                    .environment(loginVM)
            }
        } else {
            LoginView().environment(loginVM)
        }
        //TODO: reset create album form when done
        //TODO: searchBar can search albumNames and give some suggestions
    }
    //TODO: manage albumView
}

#Preview {
    ContentView()
}
