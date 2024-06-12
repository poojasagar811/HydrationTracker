//
//  File.swift
//  HydrationTracker
//
//  Created by Crescendo Worldwide India on 11/06/24.
//

import Foundation
import UIKit
import SwiftUI

struct GIFView: UIViewRepresentable {
    var gifName: String

    func makeUIView(context: Context) -> UIView {
        // Create a UIImageView to display the GIF
        let imageView = UIImageView()

        // Load the GIF
        if let gifURL = Bundle.main.url(forResource: gifName, withExtension: "gif"),
           let gifData = try? Data(contentsOf: gifURL),
           let gifImage = UIImage.gifImageWithData(gifData) {
            imageView.image = gifImage
        }

        return imageView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Update the view if needed
    }
}

// Extension to create UIImage from GIF data
extension UIImage {
    static func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        return UIImage.animatedImageWithSource(source)
    }

    static func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [UIImage]()

        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: image))
            }
        }

        return UIImage.animatedImage(with: images, duration: totalDuration(for: source))
    }

    static func totalDuration(for source: CGImageSource) -> TimeInterval {
        let count = CGImageSourceGetCount(source)
        var duration: TimeInterval = 0

        for i in 0..<count {
            if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
               let gifDict = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any],
               let frameDuration = gifDict[kCGImagePropertyGIFDelayTime as String] as? NSNumber {
                duration += frameDuration.doubleValue
            }
        }

        return duration
    }
}
