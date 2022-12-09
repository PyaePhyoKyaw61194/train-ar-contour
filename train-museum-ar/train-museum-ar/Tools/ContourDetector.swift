//
//  ContourDetector.swift
//  train-museum-ar
//
//  Created by Pyae Phyo Kyaw on 22/08/2022.
//

import Foundation
import Vision
import UIKit

class ContourDetector {
    static let shared = ContourDetector()
    private let epsilon: Float = Float( UserDefaults.standard.epsilon)
    
    private lazy var request: VNDetectContoursRequest = {
      let req = VNDetectContoursRequest()
      return req
    }()

    
    private init() {}
    
    func getFirstOutsideContour(screenImage: CIImage) -> VNContour? {
        // Perform image processing to perform contour detection
        guard let preprocessedImage = preprocessForDetectContour(screenImage: screenImage) else { return nil }
      
        let pivotStride = stride(
          from: UserDefaults.standard.minPivot,
          to: UserDefaults.standard.maxPivot,
          by: 0.1)
        let adjustStride = stride(
          from: UserDefaults.standard.minAdjust,
          to: UserDefaults.standard.maxAdjust,
          by: 0.2)
        
        for pivot in pivotStride {
          for adjustment in adjustStride {
            set(contrastPivot: pivot)
            set(contrastAdjustment: adjustment)
          }
        }
        
        // The detected image size should be the same as the clipped image. The default is 512.
        request.maximumImageDimension = Int(UserDefaults.standard.detectSize)
        request.detectsDarkOnLight = true
        
        
        // Contour detection
        let handler = VNImageRequestHandler(ciImage: preprocessedImage)
        try? handler.perform([request])
        
        // Get detection result
        guard let observation = request.results?.first as? VNContoursObservation else { return nil }
        
        // Find the path with the highest number of contour normalizedPoints among the top-level contours
        let outSideContour = observation.topLevelContours.max(by: { $0.normalizedPoints.count < $1.normalizedPoints.count })
        
        do{
            try outSideContour?.polygonApproximation(epsilon: self.epsilon)
        }catch{
            
        }
//     print(request.contrastPivot , request.contrastAdjustment )
        if let contour = outSideContour {
          
            return contour
        } else {
            return nil
        }
        
       
    }

    private func preprocessForDetectContour(screenImage: CIImage) -> CIImage? {
        let detectSize = UserDefaults.standard.detectSize
        // Widen the dark part of the image and thicken the thin line.
        // WWDC2020(https://developer.apple.com/videos/play/wwdc2020/10673/)
        // 04:06あたりで紹介されているCIMorphologyMinimumを利用。
        let blurFilter = CIFilter.morphologyMinimum()
        blurFilter.inputImage = screenImage
        blurFilter.radius = 5
        guard let blurImage = blurFilter.outputImage else { return nil }
        // Emphasize the pen line. For each RGB, set the color brighter than the threshold to 1.0.
        let thresholdFilter = CIFilter.colorThreshold()
        thresholdFilter.inputImage = blurImage
        thresholdFilter.threshold = 0.1
        guard let thresholdImage = thresholdFilter.outputImage else { return nil }
        // Limit the detection range to the center of the screen
        let screenImageSize = screenImage.extent
        
        // The image size and position will change depending on the CIMorphology Minimum filter, so use the size and position of the original image as a reference.
        let croppedImage = thresholdImage.cropped(to: CGRect(x: screenImageSize.width/2 - detectSize/2,
                                                             y: screenImageSize.height/2 - detectSize/2,
                                                             width: detectSize,
                                                             height: detectSize))
        return croppedImage
    }
    
    func set(contrastPivot: CGFloat?) {
      request.contrastPivot = contrastPivot.map { NSNumber(value: $0) }
    }

    func set(contrastAdjustment: CGFloat) {
      request.contrastAdjustment = Float(contrastAdjustment)
    }
}
