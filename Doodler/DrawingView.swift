//
//  DrawingView.swift
//  Doodler
//
//  Created by Alex Lucas on 9/16/20.
//

import UIKit

class DrawingView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    func sharedInit() {
//        layer.borderColor = UIColor.systemGray2.cgColor
//        layer.borderWidth = 1
//        layer.cornerRadius = 16
    }
    
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
