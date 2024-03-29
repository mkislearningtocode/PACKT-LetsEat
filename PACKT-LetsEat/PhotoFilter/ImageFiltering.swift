//
//  ImageFiltering.swift
//  PACKT-LetsEat
//
//  Created by Warba on 25/06/2023.
//

import UIKit
import CoreImage
import OSLog

protocol ImageFiltering {
    func apply(filter: String, originalImage: UIImage) -> UIImage
}

//MARK: - Protocol Implmentation
extension ImageFiltering {


    func apply(filter: String, originalImage: UIImage) -> UIImage {
        var logger = Logger()

        let initialCIImage = CIImage(image: originalImage,
                                     options: nil)
        let originalOrientation = originalImage.imageOrientation

        guard let ciFilter = CIFilter(name: filter)
        else {
            logger.error("filter not found")
            return originalImage
        }
        ciFilter.setValue(initialCIImage, forKey: kCIInputImageKey)

        let context = CIContext()
        let filteredCIImage = (ciFilter.outputImage)!
        let filteredCGImage = context.createCGImage(filteredCIImage, from: filteredCIImage.extent)
        return UIImage(cgImage: filteredCGImage!,
                       scale: 1.0,
                       orientation: originalOrientation)
    }
}
