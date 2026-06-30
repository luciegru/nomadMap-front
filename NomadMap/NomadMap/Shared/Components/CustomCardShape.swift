//
//  CustomCardShape.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 03/06/2026.
//

import SwiftUI

struct CustomCardShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let bottomY = rect.maxY - 20
        let radius: CGFloat = 15
        path.move(to: CGPoint(x: rect.minX + radius, y: rect.minY))
        
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
                path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + radius),
                          control: CGPoint(x: rect.maxX, y: rect.minY))
        
        path.addLine(to: CGPoint(x: rect.maxX, y: bottomY - radius))
        
        path.addQuadCurve(to: CGPoint(x: rect.maxX - radius, y: bottomY),
                          control: CGPoint(x: rect.maxX, y: bottomY))
        
        path.addLine(to: CGPoint(x: rect.midX + 12, y: bottomY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY)) // Touche le vrai bas
        path.addLine(to: CGPoint(x: rect.midX - 12, y: bottomY))
        
        path.addLine(to: CGPoint(x: rect.minX + radius, y: bottomY))
        
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: bottomY - radius),
                          control: CGPoint(x: rect.minX, y: bottomY))
        
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        
        path.addQuadCurve(to: CGPoint(x: rect.minX + radius, y: rect.minY),
                          control: CGPoint(x: rect.minX, y: rect.minY))
        
        path.closeSubpath()
        return path
    }
    
}

#Preview {
    CustomCardShape()
        .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))

}
