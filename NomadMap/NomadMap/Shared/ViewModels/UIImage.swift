import CoreImage
import UIKit
import SwiftUI

extension UIImage {
    func dominantColor() -> Color? {
        guard let ciImage = CIImage(image: self) else { return nil }
        
        let extentVector = CIVector(x: ciImage.extent.origin.x,
                                     y: ciImage.extent.origin.y,
                                     z: ciImage.extent.size.width,
                                     w: ciImage.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage",
                                     parameters: [kCIInputImageKey: ciImage,
                                                  kCIInputExtentKey: extentVector]),
              let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        context.render(outputImage,
                        toBitmap: &bitmap,
                        rowBytes: 4,
                        bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                        format: .RGBA8,
                        colorSpace: nil)
        
        return Color(red: Double(bitmap[0]) / 255,
                     green: Double(bitmap[1]) / 255,
                     blue: Double(bitmap[2]) / 255)
    }
}
