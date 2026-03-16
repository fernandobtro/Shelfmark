//
//  ImageStorage.swift
//  Shelfmark
//
//  Created by Fernando Buenrostro on 15/03/26.
//

import Foundation
import UIKit

enum ImageStorageError: Error {
    case jpegDataFailed
    case writeFailed
}

enum ImageStorage {
    static func saveDownscaledCover(_ image: UIImage, maxDimension: CGFloat = 1000, compressionQuality: CGFloat = 0.75) throws -> URL {
        let originalSize = image.size
        let maxSide = max(originalSize.width, originalSize.height)
        let scale = maxSide > maxDimension ? maxDimension / maxSide: 1.0
        let targetSize = CGSize(width: originalSize.width * scale, height: originalSize.height * scale)
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        let downscaled = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        
        guard let jpegData = downscaled.jpegData(compressionQuality: compressionQuality) else {
            throw ImageStorageError.jpegDataFailed
        }
        
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let fileName = "cover-\(UUID().uuidString).jpg"
        let fileURL = cachesURL.appendingPathComponent(fileName)
        
        do {
            try jpegData.write(to: fileURL, options: [.atomic])
            return fileURL
        } catch {
            throw ImageStorageError.writeFailed
        }
    }
}
