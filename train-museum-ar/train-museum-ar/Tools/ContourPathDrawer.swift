//
//  ContourDrawer.swift
//  train-museum-ar
//
//  Created by Pyae Phyo Kyaw on 22/08/2022.
//

import Foundation
import UIKit
import Vision
class ContourPathDrawer {
    
    private var contourPathLayer: CAShapeLayer?
    
    static let shared = ContourPathDrawer()
    let detectSize: CGFloat = UserDefaults.standard.detectSize
    
    private init(){}
    
    func drawContourPath(_ path: CGPath, view: UIView) {
    
        // Delete the displayed path
        if let layer = self.contourPathLayer {
            layer.removeFromSuperlayer()
            self.contourPathLayer = nil
        }
        // 輪郭を描画
        let pathLayer = CAShapeLayer()
        var frame = view.bounds
        frame.origin.x = frame.width/2 - detectSize/2
        frame.origin.y = frame.height/2 - detectSize/2
        frame.size.width = detectSize
        frame.size.height = detectSize
        pathLayer.frame = frame
        pathLayer.path = path
        pathLayer.strokeColor = UIColor.blue.cgColor
        pathLayer.lineWidth = 10
        pathLayer.fillColor = UIColor.clear.cgColor
        view.layer.addSublayer(pathLayer)
        self.contourPathLayer = pathLayer
    }
    
    func getCGPathInUIKitSpace(contour: VNContour) -> CGPath? {
        // For use with UIKit, enlarge it to the size when it was clipped, invert the upper and lower coordinates, and make the upper left (0,0).
        let path = contour.normalizedPath
        var transform = CGAffineTransform(scaleX: detectSize, y: -detectSize)
        transform = transform.concatenating(CGAffineTransform(translationX: 0, y: detectSize))
        let transPath = path.copy(using: &transform)
        return transPath
    }
}
