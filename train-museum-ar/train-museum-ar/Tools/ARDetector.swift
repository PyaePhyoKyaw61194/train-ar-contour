//
//  ARDtector.swift
//  train-museum-ar
//
//  Created by Pyae Phyo Kyaw on 22/08/2022.
//

import Foundation
import ARKit
import UIKit
class ARDetector {
    static let shared = ARDetector()
    
    private init(){}
    
    func cropScreenImageFromCapturedImage(frame: ARFrame, scnView : ARSCNView) -> CIImage {

        let imageBuffer = frame.capturedImage
        // カメラキャプチャ画像をスクリーンサイズに変換
        // 参考 : https://stackoverflow.com/questions/58809070/transforming-arframecapturedimage-to-view-size
        let imageSize = CGSize(width: CVPixelBufferGetWidth(imageBuffer), height: CVPixelBufferGetHeight(imageBuffer))
        let viewPortSize = scnView.bounds.size
        let interfaceOrientation  = scnView.window!.windowScene!.interfaceOrientation
        let image = CIImage(cvImageBuffer: imageBuffer)
       
        // 1) Convert to "normalized image coordinates"
        let normalizeTransform = CGAffineTransform(scaleX: 1.0/imageSize.width, y: 1.0/imageSize.height)
        // 2) 「Flip the Y axis (for some mysterious reason this is only necessary in portrait mode)」
        var flipTransform = CGAffineTransform.identity
        if interfaceOrientation.isPortrait {
            // flip X and Y Axis
            flipTransform = CGAffineTransform(scaleX: -1, y: -1)
            // Both the X-axis and Y-axis move to the minus side, so move to the plus side.
            flipTransform = flipTransform.concatenating(CGAffineTransform(translationX: 1, y: 1))
        }
        // 3) Apply the transformation provided by ARFrame
        // This transformation converts:
        // - From Normalized image coordinates (Normalized image coordinates range from (0,0) in the upper left corner of the image to (1,1) in the lower right corner)
        // - To view coordinates ("a coordinate space appropriate for rendering the camera image onscreen")
        // See also: https://developer.apple.com/documentation/arkit/arframe/2923543-displaytransform
        let displayTransform = frame.displayTransform(for: interfaceOrientation, viewportSize: viewPortSize)
        // 4) Convert to view size( from 0.0 to 1.0 coordinate system to screen coordinate system )
        let toViewPortTransform = CGAffineTransform(scaleX: viewPortSize.width, y: viewPortSize.height)
        // 5) Transform the image and crop it to the viewport(screen size)
        let transformedImage = image.transformed(by: normalizeTransform.concatenating(flipTransform).concatenating(displayTransform).concatenating(toViewPortTransform)).cropped(to: scnView.bounds)
        return transformedImage
    }
}
