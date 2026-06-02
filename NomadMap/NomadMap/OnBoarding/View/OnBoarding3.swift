//
//  OnBoarding3.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 12/05/2026.
//

import SwiftUI

struct OnBoarding3: View {
    @State private var isVisible = false
    @Environment(LoginViewModel.self) private var loginVM
    
    var body: some View {
        
        NavigationStack {
            VStack {
                ZStack{
                    Ellipse()
                        .customGradient()
                        .frame(width: 250, height: 100)
                        .blur(radius: 50)
                        .opacity(0.6)
                    
                    VStack{
                        if isVisible {
                            
                            Text("TUTO_1")
                                .font(.largeTitle)
                                .bold()
                                .customGradient()
                                .padding(.horizontal, 30)
                            
                                .transition(.move(edge: .leading).combined(with: .opacity))
                            
                        }
                        
                        Spacer()
                        
                            Text("ADD_FIRSTS_INFOS")
                                .foregroundStyle(Color.gray)

                        Spacer()
                        
                        HStack{
                            Spacer()
                                NavigationLink(destination: {
                                    OnBoarding4().environment(loginVM)
                                }, label: {
                                    GoButton(muted:false)
                                })
                            
                        }.padding(.bottom, 60)
                            .padding(.trailing, 30)
                        
                    }.padding(.top, 100)
                }}
            
            .onAppear {
                withAnimation(.spring(bounce: 0.5)) {
                    isVisible = true
                }
                
            }
   
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .ignoresSafeArea()
            
            
        }.navigationBarBackButtonHidden()
    }
}

#Preview {
    OnBoarding3()
}
