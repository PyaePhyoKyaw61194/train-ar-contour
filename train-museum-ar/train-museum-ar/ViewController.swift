import ARKit
import Vision
import CoreImage.CIFilterBuiltins
import SwiftUI
import UIKit

class ViewController: UIViewController, ARSessionDelegate, ARSCNViewDelegate {

    @IBOutlet weak var scnView: ARSCNView!

    
    @IBOutlet weak var contourImgView1: UIImageView!
    @IBOutlet weak var contourImgView2: UIImageView!
    @IBOutlet weak var contourImgView3: UIImageView!
    @IBOutlet weak var contourImgView4: UIImageView!
    
    private let detectSize: CGFloat = UserDefaults.standard.detectSize
    private var isDetectButtonPressed = false
        
    let imageDrawer = ImageDrawer.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupScene()
        // AR Session 開始
        self.scnView.delegate = self
        self.scnView.session.delegate = self
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        self.scnView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
        self.imageDrawer.setImages(Img1: contourImgView1, Img2: contourImgView2, Img3: contourImgView3, Img4: contourImgView4)
    
    }

    // ARフレームが更新された
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let contourDetector = ContourDetector.shared
        let ARDetector = ARDetector.shared
        let contourPathDrawer = ContourPathDrawer.shared
        // Crop the captured image to the extent that you can see it on the screen
        let screenImage = ARDetector.cropScreenImageFromCapturedImage(frame: frame,scnView: self.scnView)
        
        // Get the outermost contour
        guard let contour = contourDetector.getFirstOutsideContour(screenImage: screenImage) else { return }
        // Get CGPath of UIKit coordinate system
        guard let path = contourPathDrawer.getCGPathInUIKitSpace(contour: contour) else { return }

        DispatchQueue.main.async {
        
            contourPathDrawer.drawContourPath(path,view: self.view)
          
            // Draw contour (3D)
            let croppedImage = screenImage.cropped(to: CGRect(x: screenImage.extent.width/2 - self.detectSize/2,
                                                              y: screenImage.extent.height/2 - self.detectSize/2,
                                                              width: self.detectSize,
                                                              height: self.detectSize))
            if  self.isDetectButtonPressed {
                self.isDetectButtonPressed = false
                self.imageDrawer.addContourDataToPreviewImage(normalizedPath: contour.normalizedPath, captureImage: croppedImage)
            }
        }
    }

    private func setupScene() {
        // ディレクショナルライト追加
        let directionalLightNode = SCNNode()
        directionalLightNode.light = SCNLight()
        directionalLightNode.light?.type = .directional
        directionalLightNode.light?.castsShadow = true  // 影が出るライトにする
        directionalLightNode.light?.shadowMapSize = CGSize(width: 2048, height: 2048)   // シャドーマップを大きくしてジャギーが目立たないようにする
        directionalLightNode.light?.shadowSampleCount = 2   // 影の境界を若干柔らかくする
        directionalLightNode.light?.shadowColor = UIColor.lightGray.withAlphaComponent(0.8) // 影の色は明るめ
        directionalLightNode.position = SCNVector3(x: 0, y: 3, z: 0)
        directionalLightNode.eulerAngles = SCNVector3(x: -Float.pi/3, y: 0, z: -Float.pi/3)
        self.scnView.scene.rootNode.addChildNode(directionalLightNode)
        // 暗いので環境光を追加
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        directionalLightNode.position = SCNVector3(x: 0, y: 0, z: 0)
        self.scnView.scene.rootNode.addChildNode(ambientLightNode)

    }

    // ジオメトリ化ボタンが押された
    @IBAction func BtnPressed(_ sender: Any) {
        isDetectButtonPressed = true
    }

    @IBAction func ShowARBtnPressed(_ sender: Any) {

        let ARViewController = storyboard?.instantiateViewController(withIdentifier: "ARViewVC") as! ARViewController
        ARViewController.modalPresentationStyle = .fullScreen
        ARViewController.mainVC = self
        let contouredCGImages: [CGImage]
        contouredCGImages = self.imageDrawer.addCGImagesFromUIImages()
        
        if(contouredCGImages.count != 4){
            print("need 4 contoured Images")
            return
        }
        
        ARViewController.contourCGImages = contouredCGImages
        
        self.scnView.session.pause()
        present(ARViewController,animated: true,completion: nil)
    }
    
    @IBAction func SettingBtnPressed(_sender:Any){
        let SettingiewController = storyboard?.instantiateViewController(withIdentifier: "SettingVC") as! SettingViewController
        SettingiewController.modalPresentationStyle = .fullScreen
        SettingiewController.mainVC = self
        self.scnView.session.pause()
        present(SettingiewController,animated: true,completion: nil)
    }
}

extension SCNVector3 {
    static func + (lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3{
        return SCNVector3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }

    static func - (lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3{
        return SCNVector3(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
    }

    static func * (lhs: SCNVector3, rhs: CGFloat) -> SCNVector3{
        return SCNVector3(lhs.x * Float(rhs), lhs.y * Float(rhs), lhs.z * Float(rhs))
    }

    static func / (lhs: SCNVector3, rhs: Float) -> SCNVector3{
        return SCNVector3(lhs.x / rhs, lhs.y / rhs, lhs.z / rhs)
    }
}

extension CGPoint {
    static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint{
        return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
}

extension Float {
    var cg: CGFloat { CGFloat(self) }
}
