//
//  LoginView.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 27/04/2026.
//

import SwiftUI

struct LoginView: View {
    
    @State var email: String = ""
    @State var password: String = ""
    @State var response: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @Environment(LoginViewModel.self) private var loginVM
    
    var body: some View {
        
        NavigationStack {
            VStack(){
                
                ZStack{
                    Rectangle()
                        .frame(width: 80, height: 80)
                        .cornerRadius(25)
                        .foregroundColor(Color("black_1"))
                        .shadow(radius: 10)
                        .customGradient()
                    
                    Text("PLANE_ICON")
                        .font(Font.system(size: 30))
                }.padding(.top, 100)
                
                
                Text("NOMAD_MAP")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding(10)
                
                Text("LOGIN_TITLE")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.gray)
                
                Spacer()
                
                CustomTextField(label: "EMAIL", placeholder: "PLACEHOLDER_EMAIL", binding: $email, secure: false, isHeightFixed: true).padding(.bottom, 20)
                
                CustomTextField(label: "PASSWORD",placeholder: "PLACEHOLDER_PASSWORD", binding: $password, secure: true, isHeightFixed: true)
                
                
                
                HStack{
                    
                    Spacer()
                    Button(action:{}, label:{
                        Text("Q_FORGOT_PASSWORD")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                            .padding(.trailing, 40)
                    })
                }.padding(.bottom, 20)
                
                Text(response)
                    .foregroundStyle(Color("orange_1"))
                    .bold()
                
                
//TODO: animations when button hover
                Button(action:{
                    response = ""
                    
                    if email.isEmpty || password.isEmpty {
                        response = AppError.wrongCredentials.errorDescription ?? "ERROR_UNKNOWN"
                    }  else {
                        
                        Task{
                            
                            do{
                            try await loginVM.login(email: email, password: password)
                            
                            
                            
                            if loginVM.isAuthenticated {
                                response = "log"
                            }
                                
                            } catch let error as AppError {
                                            showAlert = true
                                            alertMessage = error.errorDescription ?? ""
                                        } catch {
                                            alertMessage = "Impossible de charger les données de l'album. Vérifie ta connexion."
                                            showAlert = true
                                        }
                                        
                        }
                    }
                }, label:{
                    
                    ZStack{
                        
                        Rectangle()
                            .frame(width: 200, height: 50)
                            .cornerRadius(15)
                            .foregroundColor(Color("black_1"))
                            .shadow(radius: 10)
                            .customGradient()
                        
                        
                        
                        Text("BUTTON_GO")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                })
                
                
                HStack{
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(Color.gray.opacity(0.5))
                    
                    Text("DIVIDER_OR")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(Color.gray.opacity(0.5))
                }.padding(.horizontal, 40)
                    .padding(.vertical, 20)
                
                
                Button(action:{}, label: {
                    CustomBlackButton(text: "BUTTON_GOOGLE", image: "google_logo")
                        .padding(.horizontal, 40)
                })
                
                NavigationLink {
                    SignupView()
                } label: {
                    Text("BUTTON_SIGNUP")
                        .customGradient()
                        .padding(.vertical, 20)
                        .bold()
                }
                
                Spacer()
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .ignoresSafeArea()
            .alert("Oops 🙃", isPresented: $showAlert, actions: {
                Button("OK", role: .cancel) { }
            }, message: {
                Text(alertMessage)
            })

            
        }.navigationBarBackButtonHidden()
    }
    
}


#Preview {
    LoginView().environment(LoginViewModel())
}
