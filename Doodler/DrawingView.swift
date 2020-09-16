//
//  DrawingView.swift
//  Doodler
//
//  Created by Alex Lucas on 9/16/20.
//

import UIKit

class DrawingView: UIView {
    
    var drawingLayer = CAShapeLayer()
    let path = UIBezierPath()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        drawingLayer.fillColor = nil
        drawingLayer.strokeColor = UIColor.label.cgColor
        
        layer.addSublayer(drawingLayer)

    }
    
    func drawStarted(at point: CGPoint) {
        path.move(to: point)
    }
    
    func drawMoved(to point: CGPoint) {
        path.addLine(to: point)
        drawingLayer.path = path.cgPath
    }
    
    func drawEnded() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
