
import UIKit
import ARKit

class ARViewController: UIViewController,ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    private var isAlreadyAdded = false
    
    var mainVC: ViewController!
    
    var contourCGImages: [CGImage]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        //        sceneView.debugOptions = .showFeaturePoints
        //        let scene = SCNScene()
        //        sceneView.scene = scene
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
         configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {


        if(isAlreadyAdded == true){
            return
        }
        
        
        isAlreadyAdded = true
         let planeAnchor = anchor
        // let planeNode = SCNNode()
         let x = planeAnchor.transform.columns.3.x
         let y = planeAnchor.transform.columns.3.y
         let z = planeAnchor.transform.columns.3.z
        //planeNode!.position = SCNVector3(x: x, y: y, z: z)
     
        let trainScene = SCNScene(named: "train.scnassets/Train220815_1.usdz")!
        
        guard let trainNode = trainScene.rootNode.childNode(withName: "main", recursively: true) else {
            fatalError("main model is not found")
        }
        
        trainNode.position = SCNVector3(x,y,z)
        trainNode.scale = SCNVector3(0.02,0.02,0.02)
        sceneView.scene.rootNode.addChildNode(trainNode)
        addCIImageToTrainModel()
    }
    
    @IBAction func BackBtnPressed(_ sender: Any) {

        let mainController = mainVC!
        mainController.modalPresentationStyle = .fullScreen
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        mainController.scnView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
        
        
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
        node.removeFromParentNode() }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func addCIImageToTrainModel(){
       
        if(contourCGImages == nil || contourCGImages.count != 4){
            print("not enough images")
            return;
        }
        
        print("Ready to change")
        
        for i in 0...3 {
           switch(i){
            case 0:
               let wrappingANode =  self.sceneView.scene.rootNode.childNode(withName: "main", recursively: true)?.childNode(withName: "Wrapping_A", recursively: true)
               wrappingANode?.geometry?.firstMaterial?.diffuse.contents = contourCGImages[i];
               
               let wrappingENode =  self.sceneView.scene.rootNode.childNode(withName: "main", recursively: true)?.childNode(withName: "Wrapping_E", recursively: true)
               wrappingENode?.geometry?.firstMaterial?.diffuse.contents = contourCGImages[i];
               
            case 1:
               let wrappingBNode =  self.sceneView.scene.rootNode.childNode(withName: "main", recursively: true)?.childNode(withName: "Wrapping_B", recursively: true)
               wrappingBNode?.geometry?.firstMaterial?.diffuse.contents = contourCGImages[i];
               
               let wrappingFNode =  self.sceneView.scene.rootNode.childNode(withName: "main", recursively: true)?.childNode(withName: "Wrapping_F", recursively: true)
               wrappingFNode?.geometry?.firstMaterial?.diffuse.contents = contourCGImages[i];
            case 2:
               let wrappingCNode =  self.sceneView.scene.rootNode.childNode(withName: "main", recursively: true)?.childNode(withName: "Wrapping_C", recursively: true)
               wrappingCNode?.geometry?.firstMaterial?.diffuse.contents = contourCGImages[i];
               
               let wrappingGNode =  self.sceneView.scene.rootNode.childNode(withName: "main", recursively: true)?.childNode(withName: "Wrapping_G", recursively: true)
               wrappingGNode?.geometry?.firstMaterial?.diffuse.contents = contourCGImages[i];
            case 3:
               let wrappingDNode =  self.sceneView.scene.rootNode.childNode(withName: "main", recursively: true)?.childNode(withName: "Wrapping_D", recursively: true)
               wrappingDNode?.geometry?.firstMaterial?.diffuse.contents = contourCGImages[i];
               
               let wrappingHNode =  self.sceneView.scene.rootNode.childNode(withName: "main", recursively: true)?.childNode(withName: "Wrapping_H", recursively: true)
               wrappingHNode?.geometry?.firstMaterial?.diffuse.contents = contourCGImages[i];
           default:
               break;
           }
        }
    }
}
