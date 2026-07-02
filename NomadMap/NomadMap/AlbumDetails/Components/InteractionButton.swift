//
//  InteractionButton.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 01/07/2026.
//

import SwiftUI


struct InteractionButton: View {
    let icon: String
    let color: String
    let count: Int?
    let isActive: Bool
    let action: (() -> Void)?
    
    var body: some View {
        Button(action: { action?() }) {
            VStack(spacing: 4) {
                Image(systemName: isActive ? "\(icon).fill" : icon)
                    .font(.system(size: 28))
                    .foregroundStyle(Color(color))
                if let count = count {
                    Text(count >= 1000 ? "\(count / 1000)K" : "\(count)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color(color))
                } else {
                    Rectangle()
                        .foregroundStyle(Color.clear)
                        .frame(width: 5, height: 12)
                }
            }.frame(height: 60)
        }
        .disabled(action == nil)
    }
}
