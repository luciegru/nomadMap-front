//
//  SignupView.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 30/04/2026.
//

import SwiftUI

struct SignupView: View {
    
    @State var name: String = ""
    @State var firstname: String = ""
    @State var username: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var passwordConfirmation: String = ""
    @State var response: String = ""
    @Environment(LoginViewModel.self) private var loginVM
    
    var body: some View {
        
        NavigationStack{
            ZStack{
                VStack{
                    ZStack{
                        Rectangle()
                            .frame(width: 80, height: 80)
                            .cornerRadius(25)
                            .foregroundColor(.red)
                            .shadow(radius: 10)
                            .customGradient()
                        
                        Text("PLANE_ICON")
                            .font(Font.system(size: 30))
                    }.padding(.top, 60)

                    
                    Text("Q_NEW_HERE")
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    VStack(){
                        ScrollView{
                            
                            CustomTextField(label: "NAME", placeholder: "PLACEHOLDER_NAME", binding: $name, secure: false)
                            
                            Spacer()
                            
                            CustomTextField(label: "FIRSTNAME", placeholder: "PLACEHOLDER_FIRSTNAME", binding: $firstname, secure: false)
                            
                            Spacer()
                            
                            CustomTextField(label: "USERNAME", placeholder: "PLACEHOLDER_USERNAME", binding: $username, secure: false)
                            
                            Spacer()
                            
                            CustomTextField(label: "EMAIL", placeholder: "PLACEHOLDER_EMAIL", binding: $email, secure: false)
                            
                            
                            Spacer()
                            
                            
                            
                            CustomTextField(label: "PASSWORD", placeholder: "PLACEHOLDER_PASSWORD", binding: $password, secure: true)
                            
                            Spacer()
                            
                            CustomTextField(label: "CONFIRM_PASSWORD", placeholder: "PLACEHOLDER_CONFIRM_PASSWORD", binding: $passwordConfirmation, secure: true)
                        }
                        }.padding(.vertical, 20)
                    
                    Text(response)
                        .foregroundStyle(Color("orange_1"))
                        .bold()

// TODO: links
                        Text("TERMS_OF_SERVICE_PT_1")
                            .foregroundStyle(Color.gray)
                        Button(action:{}, label: {
                            Text("TERMS_OF_SERVICE_BTN_1")
                                .customGradient()
                        })
                    HStack(){
                        Text("TERMS_OF_SERVICE_PT_2")
                            .foregroundStyle(Color.gray)
                        Button(action:{}, label: {
                            Text("TERMS_OF_SERVICE_BTN_2")
                                .customGradient()
                        })
                    }
                    
                    Button(action:{
                        response = ""
                        if password != passwordConfirmation {
                            response = LoginError.passwordMismatch.errorDescription ?? "ERROR_UNKNOWN"
                        } else if name.isEmpty || firstname.isEmpty || email.isEmpty || password.isEmpty || passwordConfirmation.isEmpty {
                            response = LoginError.allFieldsEmpty.errorDescription ?? "ERROR_UNKNOWN"
                        } else if !loginVM.isValidEmail(email) {
                            response = LoginError.emailNotValid.errorDescription ?? "ERROR_UNKNOWN"
                        } else {
                            Task {
                                do{
                                    try await loginVM.createUser(name: name, firstName: firstname , username: username, email: email, password: password)
                                } catch {
                                    if let error = loginVM.errorMessage {
                                        response = error.errorDescription ?? "ERROR"
                                    }
                                }
                            }
                            
                        }
                    }, label:{
                        
                        ZStack{
                            
                            Rectangle()
                                .frame(width: 200, height: 50)
                                .cornerRadius(15)
                                .foregroundColor(.red)
                                .shadow(radius: 10)
                                .customGradient()
                            
                            
                            
                            Text("CREATE_ACCOUNT")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                        }.padding()
                        
                    })

                    
                    
                    NavigationLink {
                        LoginView()
                    } label: {
                        Text("ALREADY_AN_ACCOUNT")
                            .customGradient()
                            .bold()
                            .padding(.bottom, 50)
                    }
                    
                }
                            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .ignoresSafeArea()
            
        }.navigationBarBackButtonHidden()
    }
}


#Preview {
    SignupView().environment(LoginViewModel())
}
