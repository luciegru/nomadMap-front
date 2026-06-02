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
            OnBoarding5()
                .environment(loginVM)
        } else {
            LoginView().environment(loginVM)
        }
    }
}

#Preview {
    ContentView()
}
