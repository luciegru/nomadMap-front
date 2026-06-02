//
//  CustomGradientButton.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 13/05/2026.
//

import SwiftUI

struct CustomGradientButton: View {
    var text: LocalizedStringKey
    var image: String?
    var muted: Bool
    
    var body: some View {
        
        ZStack{
            if !muted {
                RoundedRectangle(cornerRadius: 10)
                    .customGradient()
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color("orange_1").opacity(0.1))
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
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
            }
            HStack{
                if let image = image {
                    Image(image)
                        .font(.system(size: 20))
                        .padding(.trailing, 10)
                }
                Text(text)
                    .foregroundStyle(Color.white)
                    .bold()
            }
        }
    }
}

#Preview {
    CustomGradientButton(text:"THIS IS A BUTTON", muted: true)
}
