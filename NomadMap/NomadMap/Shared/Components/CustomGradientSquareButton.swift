//
//  CustomGradientSquareButton.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 03/06/2026.
//

import SwiftUI

struct CustomGradientSquareButton: View {
    var text: LocalizedStringKey?
    var image: String?
    var muted: Bool
    
    var body: some View {
        
        ZStack{
            if !muted {
                RoundedRectangle(cornerRadius: 10)
                    .customGradient()
                    .frame(width: 45, height: 45)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color("orange_1").opacity(0.1))
                    .frame(width: 45, height: 45)
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
                    Image(systemName: image)
                        .font(.system(size: 20))
                        .foregroundStyle(Color.white)
                }
                if let text = text {
                    Text(text)
                        .foregroundStyle(Color.white)
                        .bold()
                }
            }
        }
    }
}

#Preview {
    CustomGradientSquareButton(image:"person.fill", muted: true)
}
