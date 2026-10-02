//
//  OnBoarding1.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 12/05/2026.
//

import SwiftUI

struct OnBoarding1: View {
    
    @State private var viewModel = OnboardingViewModel()
    @Environment(LoginViewModel.self) private var loginVM
    @State private var isVisible = false
    private var introductionText: LocalizedStringResource = "WELCOME_TEXT"
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    
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
                            
                            Text("U_WELCOME")
                                .font(.largeTitle)
                                .bold()
                                .customGradient()
                            
                                .transition(.move(edge: .leading).combined(with: .opacity))
                            
                        }
                        
                        Spacer()
                        
                        Text(viewModel.displayedText)
                            .foregroundStyle(Color.gray)
                            .padding(.horizontal, 30)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                        
                        HStack{
                            Spacer()
                            
                            NavigationLink(destination: {
                                Onboarding2().environment(loginVM)
                            }, label: {
                                GoButton(muted: false)
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
            .alert("Oops 🙃", isPresented: $showAlert, actions: {
                Button("OK", role: .cancel) { }
            }, message: {
                Text(alertMessage)
            })

            
            .task {
                let translated = String(localized: introductionText)
                await viewModel.typeWriterEffect(translationKey: translated)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .ignoresSafeArea()
            
            
        }.navigationBarBackButtonHidden()
    }
}
#Preview {
    OnBoarding1().environment(LoginViewModel())
}

