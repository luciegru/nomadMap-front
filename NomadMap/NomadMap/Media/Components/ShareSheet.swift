//
//  ShareSheet.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 04/09/2026.
//


import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    var excludedActivityTypes: [UIActivity.ActivityType]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        controller.excludedActivityTypes = excludedActivityTypes

        if let popover = controller.popoverPresentationController {
            if let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first,
               let rootView = windowScene.windows.first(where: \.isKeyWindow)?.rootViewController?.view {
                popover.sourceView = rootView
                popover.sourceRect = CGRect(
                    x: rootView.bounds.midX,
                    y: rootView.bounds.maxY,
                    width: 0,
                    height: 0
                )
                popover.permittedArrowDirections = []
            }
        }

        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
