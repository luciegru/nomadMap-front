//
//  CustomGradient.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 27/04/2026.
//

import SwiftUI


extension View {
    @ViewBuilder
    func customGradient(
        gradient: Gradient = Gradient(colors: [Color("red_1", bundle: .main), Color("orange_1", bundle: .main)]),
        startPoint: UnitPoint = .bottomTrailing,
        endPoint: UnitPoint = .topLeading
    ) -> some View {
        self
            .overlay(
                LinearGradient(
                    gradient: gradient,
                    startPoint: startPoint,
                    endPoint: endPoint
                )
            )
            .mask(self)
    }
}

