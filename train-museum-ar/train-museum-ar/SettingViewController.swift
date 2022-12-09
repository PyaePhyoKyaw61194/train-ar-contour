//
//  SettingViewController.swift
//  train-museum-ar
//
//  Created by Pyae Phyo Kyaw on 22/08/2022.
//

import Foundation
import UIKit
import ARKit
class SettingViewController: UIViewController{
    var mainVC: ViewController!

    @IBOutlet weak var minContrastAdjSlider: UISlider!
    @IBOutlet weak var minContrastAdjLabel: UILabel!
    
    @IBOutlet weak var maxContrastAdjSlider: UISlider!
    @IBOutlet weak var maxContrastAdjLabel: UILabel!
    
    @IBOutlet weak var minContrastPivotSlider: UISlider!
    @IBOutlet weak var minContrastPivotLabel: UILabel!
    
    @IBOutlet weak var maxContrastPivotSlider: UISlider!
    @IBOutlet weak var maxContrastPivotLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        minContrastAdjSlider.minimumValue = 0
        minContrastAdjSlider.maximumValue = 3
        minContrastAdjSlider.value = Float(UserDefaults.standard.minAdjust)
        minContrastAdjLabel.text = "Min contrast Adjustment : " +  String(format: "%.01f",UserDefaults.standard.minAdjust);
        
        
        maxContrastAdjSlider.minimumValue = 0
        maxContrastAdjSlider.maximumValue = 3
        maxContrastAdjSlider.value = Float(UserDefaults.standard.maxAdjust)
        maxContrastAdjLabel.text = "Max Contrast Adjustment : " +  String(format: "%.01f",UserDefaults.standard.maxAdjust);
        
        minContrastPivotSlider.minimumValue = 0
        minContrastPivotSlider.maximumValue = 1
        minContrastPivotSlider.value = Float(UserDefaults.standard.minPivot)
        minContrastPivotLabel.text = "Min Contrast Pivot : " +  String(format: "%.01f",UserDefaults.standard.minPivot);
        
        
        maxContrastPivotSlider.minimumValue = 0
        maxContrastPivotSlider.maximumValue = 1
        maxContrastPivotSlider.value = Float(UserDefaults.standard.maxPivot)
        maxContrastPivotLabel.text = "Max Contrast Pivot : " +  String(format: "%.01f",UserDefaults.standard.maxPivot);
    
    }
    
    
    @IBAction func MinAdjValueChanged(_ sender: Any) {
        UserDefaults.standard.minAdjust = CGFloat(minContrastAdjSlider.value);
        
        minContrastAdjLabel.text = "Min Contrast Adjustment : " +  String(format: "%.01f",UserDefaults.standard.minAdjust);
    }
    
    @IBAction func MaxAdjValueChanged(_ sender: Any) {
        
        UserDefaults.standard.maxAdjust = CGFloat(maxContrastAdjSlider.value);
        
        maxContrastAdjLabel.text = "Max Contrast Adjustment : " +  String(format: "%.01f",UserDefaults.standard.maxAdjust);
    }
 
    @IBAction func MinPivotValueChanged(_ sender: Any) {
        UserDefaults.standard.minPivot = CGFloat(minContrastPivotSlider.value);
        
        minContrastPivotLabel.text = "Min Contrast Pivot : " +  String(format: "%.01f",UserDefaults.standard.minPivot);
    }
    
    @IBAction func MaxPivotValueChanged(_ sender: Any) {
        
        UserDefaults.standard.maxPivot = CGFloat(maxContrastPivotSlider.value);
        
        maxContrastPivotLabel.text = "Max contrast Pivot : " +  String(format: "%.01f",UserDefaults.standard.maxPivot);
    }
    
    @IBAction func BackBtnPressed(_ sender: Any) {
        let mainController = mainVC!
        mainController.modalPresentationStyle = .fullScreen
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        mainController.scnView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
        self.dismiss(animated: true, completion: nil)
    }
  
}
