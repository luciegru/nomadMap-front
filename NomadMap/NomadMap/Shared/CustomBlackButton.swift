//
//  CustomBlackButton.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 28/04/2026.
//

import SwiftUI

struct CustomBlackButton: View {
    
    var text: LocalizedStringKey
    var image: String?
    
    var body: some View {
        
        ZStack{
            
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.1))
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(
                            Color.gray.opacity(0.5),
                            lineWidth: 1
                        )
                )
            HStack{
                if let image = image {
                    Image(image)
                        .font(.system(size: 20))
                        .padding(.trailing, 10)
                }
                Text(text)
                    .foregroundStyle(Color.white)
            }
        }
    }
}


#Preview {
    CustomBlackButton(text: "Continue with Google", image: "google_logo")
}
