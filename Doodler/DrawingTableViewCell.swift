//
//  DrawingTableViewCell.swift
//  Doodler
//
//  Created by Alex Lucas on 9/17/20.
//

import UIKit

class DrawingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var thumbnailView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var deleteLabel: UILabel!
    @IBOutlet weak var deleteTrailingConstraint: NSLayoutConstraint!
    
    var drawing: Drawing! {
        didSet {
            dateLabel?.text = drawing.id
            for thumbnailLayer in drawing.thumbnail {
                thumbnailView.layer.addSublayer(thumbnailLayer)

            }
        }
    }
    var deleteDelegate: DrawingDeleteDelegate!
    
    var initialTouchPoint: CGPoint?
    var initialFrame: CGRect?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(swipe))
        
        pan.delegate = self
        view.addGestureRecognizer(pan)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @objc func swipe(_ sender: UIScreenEdgePanGestureRecognizer) {
        let touchPoint = sender.location(in: self.view.window)
        
        if sender.state == .began {
            initialTouchPoint = touchPoint
            initialFrame = view.frame
            
        }
        let half = initialFrame!.width / 2
        if sender.state == .changed {
            let diff =  initialTouchPoint!.x - touchPoint.x
            if diff > 0 {
                self.view.frame = .init(x: initialFrame!.minX - diff , y: initialFrame!.minY, width: self.view.frame.width, height: self.view.frame.height)
                
                if diff > half {
                    UIView.animate(withDuration: 0.2) {
                        self.deleteTrailingConstraint.constant = (diff - self.deleteLabel.frame.width - 10)
                        self.view.layoutIfNeeded()
                    }
                }
                else {
                    UIView.animate(withDuration: 0.2) {
                        self.deleteTrailingConstraint.constant = 10
                        self.view.layoutIfNeeded()

                    }
                }
            }
            
            
           
        }
        if sender.state == .ended || sender.state == .cancelled {
            print("Touch Endeded")
            let diff = touchPoint.x - initialTouchPoint!.x

            print(diff)
            if  initialTouchPoint!.x - touchPoint.x > half {
                print("DELETE")
                view.translatesAutoresizingMaskIntoConstraints = true
                deleteView.translatesAutoresizingMaskIntoConstraints = true

                let target = CGRect(x: self.initialFrame!.minX - self.initialFrame!.width - 50, y: self.initialFrame!.minY, width: self.view.frame.width, height: self.view.frame.height)
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.view.frame = target
                    self.deleteLabel.alpha = 0
                    self.deleteLabel.frame = .init(x: target.minX, y: target.midY - self.deleteLabel.frame.height / 2, width: self.deleteLabel.frame.width, height: self.deleteLabel.frame.height)
                    self.deleteView.frame = .init(x: self.initialFrame!.minX, y: self.initialFrame!.minY, width: self.view.frame.width, height: 0)

                }) { (moo) in
                    self.view.alpha = 0
                    self.deleteView.alpha = 0
                    self.view.frame = self.initialFrame!
                    self.deleteView.frame = self.initialFrame!
                    self.deleteDelegate.didDeleteDrawing(self.drawing)
                    
                }
                
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = self.initialFrame!
                    self.deleteTrailingConstraint.constant = 10
                    self.view.layoutIfNeeded()

                })
                
            }
        }
        
    }

}
