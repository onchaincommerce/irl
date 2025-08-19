//
//  QRCodeView.swift
//  IRLClip
//
//  Created by Aus Heller on 8/18/25.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeView: View {
    let url: String
    let size: CGFloat
    
    var body: some View {
        Image(uiImage: generateQRCode(from: url))
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
    
    private func generateQRCode(from string: String) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"
        
        if let outputImage = filter.outputImage {
            let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return UIImage()
    }
}

#Preview {
    QRCodeView(url: "https://irl.app/claim/test123", size: 200)
}
