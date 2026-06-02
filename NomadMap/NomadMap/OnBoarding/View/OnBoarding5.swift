//
//  OnBoarding5.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 15/05/2026.
//

import SwiftUI

struct OnBoarding5: View {
    @State private var isVisible: Bool = false
    @Environment(LoginViewModel.self) private var loginVM
    @State private var navigate: Bool = false
    
    
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

                            
                            VStack{
                                
                                if isVisible {
                                    
                                    Text("STORAGE")
                                        .font(Font.system(size: 33, weight: .bold))
                                        .bold()
                                        .customGradient()
                                    
                                        .transition(.move(edge: .leading).combined(with: .opacity))
                                }
                                
                                
                                Text("STORAGE_INTRO")
                                    .foregroundStyle(Color.gray)
                                    .font(Font.system(size: 16))
                                    .multilineTextAlignment(.center)
                                
                            }.padding(.bottom, 20)
                            
                            Spacer()
                            
                            VStack{
                                ScrollView{
                                    
                                    VStack(alignment: .leading){
                                        Text("WHAT_YOU_GET")
                                            .font(Font.title2)
                                            .foregroundStyle(Color.white)
                                        HStack{
                                            ZStack{
                                                Circle()
                                                    .foregroundStyle(Color("orange_1"))
                                                    .opacity(0.2)
                                                Image(systemName: "checkmark")
                                                    .foregroundStyle(Color("orange_1"))
                                                
                                            }.frame(width: 30)
                                            
                                            VStack(alignment: .leading){
                                                Text("GIVEN_FREE_STORAGE")
                                                    .foregroundStyle(Color.white)
                                                    .font(Font.title3)
                                                
                                                Text("GIVEN_FREE_STORAGE_DESC")
                                                    .foregroundStyle(Color.gray)
                                            }
                                            Spacer()
                                        }
                                        HStack{
                                            ZStack{
                                                Circle()
                                                    .foregroundStyle(Color("orange_1"))
                                                    .opacity(0.2)
                                                Image(systemName: "checkmark")
                                                    .foregroundStyle(Color("orange_1"))
                                                
                                            }.frame(width: 30)
                                            
                                            VStack(alignment: .leading){
                                                Text("TARGETTED_ADDS")
                                                    .foregroundStyle(Color.white)
                                                    .font(Font.title3)
                                                
                                                Text("TARGETTED_ADDS_DESC")
                                                    .foregroundStyle(Color.gray)
                                            }
                                            Spacer()
                                            
                                        }
                                        
                                    }.padding(.bottom, 20)
                                    
                                    
                                    
                                    Spacer()
                                    
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 20)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .strokeBorder(
                                                        LinearGradient(
                                                            gradient: Gradient(colors: [Color("red_1"), Color("orange_1")]),
                                                            startPoint: .bottomTrailing,
                                                            endPoint: .topLeading
                                                        ),
                                                        lineWidth: 2
                                                    )
                                            )
                                            .frame(width: 320, height: 350)
                                            .foregroundStyle(Color.gray.opacity(0.1))
                                            .shadow(radius: 10)
                                        
                                        
                                        VStack{
                                            HStack{
                                                Image(systemName: "server.rack")
                                                    .foregroundStyle(Color.gray)
                                                
                                                Text("CURRENT_STORAGE_TITLE")
                                                    .font(Font.title2)
                                                    .foregroundStyle(Color.white)
                                                
                                                Spacer()
                                                
                                                
                                            }
                                            HStack(){
                                                Text(String(Int(loginVM.currentUser?.usedStorage ?? 3)))
                                                    .font(Font.largeTitle)
                                                    .foregroundStyle(Color.white)
                                                Text("/ 2000 Mo")
                                                    .font(Font.subheadline)
                                                    .foregroundStyle(Color.white)
                                                Spacer()
                                                
                                            }
                                            
                                            ProgressBar(maxValue: 2000, current: Int(loginVM.currentUser?.usedStorage ?? 3), width: 280)
                                                .padding(.bottom, 20)
                                                .padding(.leading, -25)
                                            
                                            ZStack{
                                                RoundedRectangle(cornerRadius: 20)
                                                    .foregroundStyle(Color("orange_1").opacity(0.3))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .strokeBorder(
                                                                Color("orange_1"),                                                    lineWidth: 2
                                                            )
                                                    )
                                                    .frame(width: 280, height: 120)
                                                    .padding(.leading, -25)
                                                Text("STORAGE_EVOLUTION_TEXT")
                                                    .foregroundStyle(Color.white)
                                                    .font(Font.system(size: 14))
                                                    .frame(width: 250)
                                                    .padding(.leading, -25)
                                                
                                            }
                                            
                                        }.padding(.leading, 25)
                                        
                                    }
                                    
                                    Spacer()
                                    
                                    VStack{
                                        HStack{
                                            Text("UPLOAD_OPTIONS")
                                                .font(.system(size: 18))
                                                .foregroundStyle(Color.white)
                                            
                                            Spacer()
                                        }
                                        PremiumComponent()
                                    }
                                    
                                }
                            
                            
                            
                            
                            HStack{
                                Spacer()
                                Button(action: {
                                    
                                    Task{
                                        try await loginVM.updateCurrentUser(with: ["accountStatus" : 1], id: loginVM.currentUser!.id)
                                    }

                                    navigate = true
                                    
                                }, label: {
                                    GoButton(muted:false)
                                })
                                
                            }.padding(.bottom, 60)
                                    .padding(.top, 20)
                            
                        }
                    }}
            }.padding(.horizontal, 30)
                .padding(.top, 100)
            
                .onAppear {
                    withAnimation(.spring(bounce: 0.5)) {
                        isVisible = true
                    }
                    
                }
            
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
                .ignoresSafeArea()
                .navigationDestination(isPresented: $navigate) {
                    //                LandingPage()
                    //                    .environment(loginVM)
                                }
            
        }
        .navigationBarBackButtonHidden()
           
    }
}

#Preview {
    OnBoarding5().environment(LoginViewModel())
}
