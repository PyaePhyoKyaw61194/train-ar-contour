import ARKit
import Vision
import CoreImage.CIFilterBuiltins
import SwiftUI
import UIKit

class ImageDrawer {
    static let shared:ImageDrawer = ImageDrawer() ;
    let detectSize:CGFloat = UserDefaults.standard.detectSize
    private var currentContourIndex:Int = 0;
    
    var contourImgView1: UIImageView!
    var contourImgView2: UIImageView!
    var contourImgView3: UIImageView!
    var contourImgView4: UIImageView!
   
    private init(){

    }
    
    public func setImages(Img1:UIImageView,Img2:UIImageView,Img3:UIImageView,Img4:UIImageView)
    {
        contourImgView1 = Img1;
        contourImgView2 = Img2;
        contourImgView3 = Img3;
        contourImgView4 = Img4;
    }
    
     func addContourDataToPreviewImage(normalizedPath: CGPath, captureImage: CIImage) {
        
        // CGpath has Vision co-ordinate system ( 0,0 lowerleft and 1,1 upper right) => converted to upperleft 0,0 and lower rigth(320,320)
        var transform = CGAffineTransform(scaleX: detectSize, y: -detectSize)
        transform = transform.concatenating(CGAffineTransform(translationX: 0, y: detectSize))
        let transPath = normalizedPath.copy(using: &transform)!

        // Fix the path drawing scale to '1px/pt' regardless of the terminal type.
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        //Draw path offscreen (fill with white)
        let pathFillImage = UIGraphicsImageRenderer(size: CGSize(width: self.detectSize, height: self.detectSize), format: format).image { context in
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.addPath(transPath)
            context.cgContext.fillPath()
        }
        // Convert drawn path to CIImage via CGImage
        let maskCGImage = pathFillImage.cgImage!
        let maskCIImage = CIImage(cgImage: maskCGImage)

        // Convert the captured image CIImage to CGImage and back to CIImage again.
        // It seems that the CIImage for texture is cropped, but when Filter is applied, the offset of the image held inside CIImage is ignored and the filter cannot be applied as expected.
        let ciContext = CIContext(options: nil)
        let captureCGImage = ciContext.createCGImage(captureImage, from: captureImage.extent)!
        let captureCIImage = CIImage(cgImage: captureCGImage)

        // Crop the captured image only inside the path
        let filter = CIFilter.multiplyCompositing()
        filter.inputImage = captureCIImage
        filter.backgroundImage = maskCIImage
     
        let texture = filter.outputImage!
        
        let backUIImage = UIImage(named: "train.scnassets/base.jpeg")!
        let textureUIImage = UIImage(ciImage: texture)
       
        let finalImage =  mergeTwoImage(originalImage: backUIImage, filterImage: textureUIImage)
        
        
        switch(currentContourIndex){
        case 0:
            contourImgView1.image = finalImage
            currentContourIndex+=1
        case 1:
            contourImgView2.image = finalImage
            currentContourIndex+=1
        case 2:
            contourImgView3.image = finalImage
            currentContourIndex+=1
        case 3:
            contourImgView4.image = finalImage
            currentContourIndex = 0
        default:
            currentContourIndex = 0;
        }
  
    }
    
    func addCGImagesFromUIImages() -> [CGImage]{
       
        var cotouredCIImages = [CGImage]()
        if(contourImgView1.image == nil || contourImgView2.image == nil ||
           contourImgView3.image == nil || contourImgView4.image == nil){
            return cotouredCIImages;
        }
        var originalImage:UIImage;
        var matImage: CGImage;
        for i in 0...3 {
           switch(i){
            case 0:
               originalImage = contourImgView1.image!;
               matImage = convertUIImagetoCIImage(originalImage: originalImage)
               cotouredCIImages.append(matImage)
            
            case 1:
               originalImage = contourImgView2.image!;
               matImage = convertUIImagetoCIImage(originalImage: originalImage)
               cotouredCIImages.append(matImage)

            case 2:
               originalImage = contourImgView3.image!;
               matImage = convertUIImagetoCIImage(originalImage: originalImage)
               cotouredCIImages.append(matImage)
            case 3:
               originalImage = contourImgView4.image!;
               matImage = convertUIImagetoCIImage(originalImage: originalImage)
               cotouredCIImages.append(matImage)
           default:
               break;
           }
        }
        return cotouredCIImages
    }
    
    func convertUIImagetoCIImage(originalImage: UIImage)->CGImage{
  
        let matImage = CIImage(image: originalImage)!
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(matImage, from: matImage.extent)!
        
        return cgImage;
    }
    
    func mergeTwoImage(originalImage:UIImage,filterImage:UIImage)-> UIImage{
        
        let size = CGSize(width: originalImage.size.width, height: originalImage.size.height)
        UIGraphicsBeginImageContext(size)
        
        let area = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        originalImage.draw(in: area)
        filterImage.draw(in: area, blendMode: .normal, alpha: 1)
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
     
        return finalImage!
    }
    
    
    
}


