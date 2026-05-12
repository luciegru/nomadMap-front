//
//  SecureTextField.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 27/04/2026.
//

import SwiftUI

struct CustomTextField: View {
    
    var label: LocalizedStringKey
    var placeholder: LocalizedStringKey
    var binding: Binding<String>
    var secure: Bool
    
    var body: some View {
        VStack(alignment: .leading){
            Text(label)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            ZStack(alignment: .leading){
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("black_1").opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
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
                
                HStack{
                    if binding.wrappedValue.isEmpty{
                        Text(placeholder)
                            .foregroundStyle(Color.gray.opacity(0.5))
                    }
                    
                    Spacer()
                }.padding(.leading, 10)
                
                
                if !secure {
                    
                    TextField("", text: binding)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.black.opacity(0.00001))
                        .foregroundStyle(Color.white)
                        .textInputAutocapitalization(.never)
                        .padding(.leading, 10)
                    
                } else {
                    SecureField("", text: binding)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.black.opacity(0.00001))
                        .foregroundStyle(Color.white)
                        .textInputAutocapitalization(.never)
                        .padding(.leading, 10)
                }
            }
        }.padding(.horizontal, 40)
        
    }
}

