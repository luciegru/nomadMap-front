//
//  ProgressBar.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 01/06/2026.
//

import SwiftUI

struct ProgressBar: View {
    var maxValue: Int
    var current: Int
    var width: Int
    @State private var isAppeared = false
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 100.0)
                .frame(width: CGFloat(width), height: 20)
                .foregroundStyle(Color.gray.opacity(0.3))
            HStack{
                RoundedRectangle(cornerRadius: 100.0)
                    .frame(width: isAppeared ? ((CGFloat(current) * CGFloat(width) / CGFloat(maxValue))) : 0, height: 22)
                    .customGradient()
                    .animation(
                        .spring(
                            response: 0.6,
                            dampingFraction: 0.55
                        ),
                        value: isAppeared ? ((CGFloat(current) * CGFloat(width) / CGFloat(maxValue))) : 0
                    )
                
                Spacer()
            }
            
        }.frame(width: CGFloat(width))
            .onAppear {
                isAppeared = true
            }
        
        
    }
}

#Preview {
    ProgressBar(maxValue: 2000, current: 300, width: 300)
}
