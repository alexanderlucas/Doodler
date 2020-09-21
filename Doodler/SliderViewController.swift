//
//  SliderViewController.swift
//  Doodler
//
//  Created by Alex Lucas on 9/21/20.
//

import UIKit
import RoundSlider
import SwiftUI

class SliderViewController: UIViewController {
    
    var slider: RoundSlider?
    var sliderData: SliderData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(sliderData.color)
    }
    
    
    @IBSegueAction func sliderSegueAction(_ coder: NSCoder) -> UIViewController? {
        if slider == nil {
            slider = RoundSlider()
        }
        
        let hc = UIHostingController(coder: coder, rootView: slider.environmentObject(sliderData).padding(0))
        hc?.view.backgroundColor = .clear
        return hc
        
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
