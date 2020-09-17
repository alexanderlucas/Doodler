//
//  DrawingView.swift
//  Doodler
//
//  Created by Alex Lucas on 9/16/20.
//

import UIKit

class DrawingView: UIView {
    
    var layers = [CAShapeLayer]()
    
    let path = UIBezierPath()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        

    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
