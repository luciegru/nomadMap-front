//
//  CustomBlackButton 2.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 12/05/2026.
//


import SwiftUI

struct GoButton: View {
    
    var muted: Bool
    
    var body: some View {
        
        ZStack{
            if !muted{
                Ellipse()
                    .customGradient()
                    .frame(width: 60, height: 60)
            } else {
                Ellipse()
                    .foregroundStyle(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                
            }
            HStack{
                Image(systemName: "arrow.right")
                    .font(.system(size: 30))
                    .foregroundStyle(Color.black)
            }
        }
    }
}


#Preview {
    GoButton(muted: true)
}
